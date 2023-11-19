//
//  File.swift
//  
//
//  Created by Michal Ziobro on 19/11/2023.
//

import Foundation

@available(iOS 15.0, *)
open class AsyncBaseService<D: IDecoder> {

    private let session: URLSession
    private let decoder: D
    private let logger: INetworkLogger

    public init(session: URLSession = .shared, logger: INetworkLogger = NetworkLogger(), decoder: D) {
        self.session = session
        self.decoder = decoder
        self.logger = logger
    }

    public func request<T>(_ requestable: Requestable) async throws -> T where T: Decodable {
        let (data, response) = try await _request(requestable)

        guard let response = response as? HTTPURLResponse, 200..<300 ~= response.statusCode else {
            if let error = decodeError(from: (data, response)) {
                throw NetworkError.api(error: error)
            } else {
                throw NetworkError.api(error: ApiError(error: "Unknown"))
            }
        }

        return try decode((data, response))
    }

    public func request(_ requestable: Requestable) async throws -> Data {
        let (data, _) = try await _request(requestable)
        return data
    }

    private func _request(_ requestable: Requestable) async throws -> (Data, URLResponse) {
        guard let request = try? requestable.asURLRequest() else {
            throw NetworkError.network(message: "Could not create URL request.")
        }

        logger.log(request: request)

        do {
            let (data, response) = try await session.data(for: request)

            if let response = response as? HTTPURLResponse {
                logger.log(statusCode: response.statusCode)
            }
            logger.log(response: response, data: data)
            return (data, response)
        } catch {
            logger.log(error: error)
            throw NetworkError.network(message: error.localizedDescription)
        }
    }

    private func decode<T>(_ output: (data: Data, response: URLResponse)) throws -> T where T: Decodable {
        switch output.response.contentType?.components(separatedBy: ";").first {
        case "application/json":
            do {
                return try decoder.decode(T.self, from: output.data)
            } catch {
                print("[DECODING ERROR]: \(error)")
                throw NetworkError.decoding(message: error.localizedDescription)
            }
        case "application/xml",
             "text/xml":
            do {
                return try decoder.decode(T.self, from: output.data)
            } catch {
                print("[DECODING ERROR]: \(error)")
                throw NetworkError.decoding(message: error.localizedDescription)
            }
        case "text/plain":
            guard T.self == String.self else {
                throw NetworkError.decoding(message: "[DECODING ERROR]: text/plain can be decoded only to String!")
            }
            return String(data: output.data, encoding: .utf8) as! T
        default:
            throw NetworkError.decoding(message: "[DECODING ERROR]: Invalid Content-Type!")
        }
    }

    private func decodeError(from output: (data: Data, response: URLResponse)) -> ApiError? {
        switch output.response.contentType {
        case "application/json":
            return try? decoder.decode(ApiError.self, from: output.data)
        case "application/xml":
            return try? decoder.decode(ApiError.self, from: output.data)
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
