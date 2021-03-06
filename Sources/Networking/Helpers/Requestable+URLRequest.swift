//
//  Router+URLRequest.swift
//  Elector
//
//  Created by Michal Ziobro on 22/02/2020.
//  Copyright © 2020 Elector.pl. All rights reserved.
//

import Foundation

// MARK: - URLRequest factory method
public extension Requestable where Self: IRouter {
    
    func asURLRequest() throws -> URLRequest {
        
        var baseUrlString = Self.baseURL
        
        if baseUrlString.last == "/" {
            baseUrlString = String(baseUrlString.prefix(baseUrlString.count-1))
        }
        
        // Path
        let urlString = isFullPath ? path : baseUrlString.appending(path)
       
        let url = try urlString.asURL()
        
        var urlRequest = URLRequest(url: url)
        
        // HTTP method
        urlRequest.httpMethod = method.rawValue
        
        // Header params
        var headers = [String: String]()
        headerParams.forEach { headers.updateValue($0.value, forKey: $0.key) }
        
        var queryParams = self.queryParams
        if case let .bearerToken(token) = authorization {
            headers.updateValue("Bearer \(token)", forKey: "Authorization")
        } else if case let .queryParams(params) = authorization {
            queryParams = params + queryParams
        }
        
        urlRequest.allHTTPHeaderFields = headers
        
        if case .jsonSerialization = bodyEncoding {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } else if case .stringAscii = bodyEncoding  {
            urlRequest.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        } else if case .formData = bodyEncoding {
            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        } else if case let .multipart(boundary) = bodyEncoding {
            urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        }
        
        // Body params
        if case .multipart = bodyEncoding {
            // skip
        } else if !bodyParams.isEmpty {
           urlRequest.httpBody = encoded(bodyParams, encoding: bodyEncoding)
        }
        
        // Query params
        urlRequest = try URLEncoding.queryString.encode(urlRequest, with: queryParams)
        
        return urlRequest
    }
}
