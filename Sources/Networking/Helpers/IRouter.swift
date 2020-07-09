//
//  File.swift
//  
//
//  Created by Michal Ziobro on 09/07/2020.
//

import Foundation

public enum Authorization {
    case noAuth
    case bearerToken(token : String)
    case queryParams(_ params: [String:Any])
}

public protocol IRouter: Requestable, Encoder {
    
    static var baseURL: String { get }
    
    var path: String { get }
    var isFullPath: Bool { get }
    
    var method: HTTPMethod { get }
        
    var headerParams: [String: String] { get }
    
    var authorization: Authorization { get }
    
    var queryParams: [String:Any] { get }
    
    var bodyParams: [String: Any] { get }
    var bodyEncoding: EncodingType { get }
    
    var files: [FileUploadInfo]? { get }
}
