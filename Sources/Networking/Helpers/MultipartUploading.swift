//
//  File.swift
//  
//
//  Created by Michal Ziobro on 09/07/2020.
//

import Foundation

public protocol MultipartUploading {
    
    func multipartFormData() throws -> Data?
}

public extension MultipartUploading {
    func multipartFormData() throws -> Data? { return nil }
}
