//
//  File.swift
//  
//
//  Created by Michal Ziobro on 09/07/2020.
//

import Foundation
@testable import Networking

enum MockRouter: IRouter {
    
    case sample
    case uploadFile
    
    static var baseURL: String = "https://mockapi.com"
    
    var path: String {
        switch self {
        case .sample:
            return "/sample"
        case .uploadFile:
            return "/upload"
       
        }
    }
    
    var isFullPath: Bool { false }
    
    var method: HTTPMethod {
        switch self {
        case .sample:
            return .get
        case .uploadFile:
            return .post
        }
    }
    
    var headerParams: [String : String] { [:] }
    
    var authorization: Authorization { .noAuth }
    
    var queryParams: [String : Any] { [:] }
    
    var bodyParams: [String : Any] { [:] }
    
    var bodyEncoding: EncodingType {
        
        switch self {
        case .uploadFile:
            return .multipart(boundary: "boundary")
        default:
            return .formData
        }
    }
    
    var files: [FileUploadInfo]? {
        
        switch self {
        case .uploadFile:
            if let file = Self.mockUploadFile {
                return [file]
            }
            return nil
        default:
            return nil
        }
    }
    
    static var mockUploadFile: FileUploadInfo? = nil
}
