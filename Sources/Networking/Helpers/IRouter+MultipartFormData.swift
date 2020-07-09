//
//  Router+MultipartFormData.swift
//  Elector
//
//  Created by Michal Ziobro on 22/02/2020.
//  Copyright © 2020 Elector.pl. All rights reserved.
//

import Foundation

// MARK: Multipart Form Data factory method
public extension IRouter {
    
    func multipartFormData() -> Data? {
        
        guard case let .multipart(boundary) = bodyEncoding else {
            print("No boundary to use with multipart/form-data")
            return nil
        }
        
        guard let files = self.files else {
            print("No files to attach to multipart/form-data")
            return nil
        }
        
        var data = Data()
        
        // add parameters
        if let params = encoded(bodyParams, encoding: bodyEncoding) {
            data.append(params)
        }
        
        // add files
        files.forEach { file in
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(file.param)\"; filename=\"\(file.name)\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: \(file.mime)\r\n\r\n".data(using: .utf8)!)
            data.append(file.data)
            
        }
        
        // end multipart HTTP data
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        return data
    }
}
