//
//  BaseService.swift
//  Elector
//
//  Created by Michal Ziobro on 22/02/2020.
//  Copyright © 2020 Elector.pl. All rights reserved.
//

import Foundation
import Combine

protocol IDecoder: TopLevelDecoder where Input == Data { }

extension JSONDecoder: IDecoder { }

class BaseService<D: IDecoder> {
    
    private let session: URLSession
    private let decoder: D
    private let logger: INetworkLogger
    
    init(session: URLSession = .shared,
         logger: INetworkLogger = NetworkLogger(),
         decoder: D) {
        self.session = session
        self.decoder = decoder
        self.logger = logger 
    }
    
    func request<T>(_ requestable: Requestable) -> AnyPublisher<T, Error> where T: Decodable {
        
        do {
            return try _request(requestable)
                .mapError { error -> Error in
                    NetworkError.network(message: error.localizedDescription)
                }
                .tryFilter { output -> Bool in
                    if let response = output.response as? HTTPURLResponse,
                        200..<300 ~= response.statusCode {
                        return true
                    } else if let error = self.decodeError(from: output) {
                        throw NetworkError.api(error: error)
                    } else {
                        throw NetworkError.api(error: ApiError(error: "Unknown"))
                    }
                }
                .flatMap(maxPublishers: .max(1)) { output in
                    self.decode(output)
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    func request(_ requestable: Requestable) -> AnyPublisher<Data, Error> {
        
        do {
            return try _request(requestable)
                .mapError { error -> Error in
                    NetworkError.network(message: error.localizedDescription)
                }
                .map { output in
                    output.data
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    private func _request(_ requestable: Requestable) throws -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLSession.DataTaskPublisher.Failure> {
        
        guard let request = try? requestable.asURLRequest() else {
            throw NetworkError.network(message: "Could not create URL request.")
        }
        
        self.logger.log(request: request)
        
        return session.dataTaskPublisher(for: request)
            .handleEvents(receiveOutput: { output in
                let (data, response) = output
                
                if let response = response as? HTTPURLResponse {
                    self.logger.log(statusCode: response.statusCode)
                }
                self.logger.log(response: response, data: data)
            }, receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.logger.log(error: error)
                default:
                    break
                }
            })
            .eraseToAnyPublisher()
    }
    
    func decode<T: Decodable>(_ output: URLSession.DataTaskPublisher.Output) -> AnyPublisher<T, Error> {
        
        switch output.response.contentType?.components(separatedBy: ";").first {
        case "application/json":
            return Just(output.data)
                .decode(type: T.self, decoder: decoder)
                .mapError { error -> Error in
                    print("[DECODING ERROR]: \(error)")
                    return NetworkError.decoding(message: error.localizedDescription)
                }
                .eraseToAnyPublisher()
        case "application/xml",
             "text/xml":
            return Just(output.data)
                .decode(type: T.self, decoder: decoder)
                .mapError { error -> Error in
                    print("[DECODING ERROR]: \(error)")
                    return NetworkError.decoding(message: error.localizedDescription)
                }
                .eraseToAnyPublisher()
        case "text/plain":
            guard T.self == String.self else {
                return Fail(error: NetworkError.decoding(message: "[DECODING ERROR]: text/plain can be decoded only to String!")).eraseToAnyPublisher()
            }
            let text = String(data: output.data, encoding: .utf8) as! T
            return Just(text)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        default:
            return Fail(error: NetworkError.decoding(message: "[DECODING ERROR]: Invalid Content-Type!")).eraseToAnyPublisher()
        }
    }
    
    func decodeError(from output: URLSession.DataTaskPublisher.Output) -> ApiError? {
        
        switch output.response.contentType {
        case "application/json":
            return try? self.decoder.decode(ApiError.self, from: output.data)
        case "application/xml":
            return try? self.decoder.decode(ApiError.self, from: output.data)
        case "text/plain":
            if let text = String(data: output.data, encoding: .utf8) {
                return ApiError(error: text)
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}

let service = BaseService(decoder: JSONDecoder())

extension URLResponse {
    
    var contentType: String? {
        return (self as? HTTPURLResponse)?.allHeaderFields["Content-Type"] as? String
    }
}
