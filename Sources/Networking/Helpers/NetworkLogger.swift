//
//  NetworkLogger.swift
//  Elector
//
//  Created by Michal Ziobro on 22/02/2020.
//  Copyright © 2020 Elector.pl. All rights reserved.
//

import Foundation

public protocol INetworkLogger {
    
    func log(request: URLRequest)
    func log(response: URLResponse?, data: Data?)
    func log(error: Error)
    func log(statusCode: Int)
    func log(multipart: Data)
}

final public class NetworkLogger: INetworkLogger {
    
    public init() { }
    
    public func log(request: URLRequest) {
        #if DEBUG
        print("------------------------")
        print("request: \(request.url!)")
        print("headers: \(request.allHTTPHeaderFields ?? [:])")
        print("method: \(request.httpMethod!)")
        if let httpBody = request.httpBody,
            let result = (try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [String: AnyObject]) {
            print("body: \(String(describing: result))")
        } else if let httpBody = request.httpBody, let resultString = String(data: httpBody, encoding: .utf8) {
            print("body: \(String(describing: resultString))")
        }
        #endif
    }
    
    public func log(response: URLResponse?, data: Data?) {
        #if DEBUG
        guard let data = data else { return }
        if let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            print("response: \(String(describing: dict))")
        } else if let string = String(data: data, encoding: .utf8) {
            print("response: \(string)")
        }
        #endif
    }
    
    public func log(error: Error) {
        #if DEBUG
        print("error: \(error)")
        #endif
    }
    
    public func log(statusCode: Int) {
        #if DEBUG
        print("statusCode: \(statusCode)")
        #endif
    }
    
    public func log(multipart data: Data) {
        #if DEBUG
        if let string = String(data: data, encoding: .ascii) {
            
            print("multipartData: " + string.prefix(500) + "(...)" + string.suffix(100))
        } else {
            print("multipartData: \(data)")
        }
        
        #endif
    }
}
