//
//  FileUploadInfo.swift
//  Elector
//
//  Created by Michal Ziobro on 22/02/2020.
//  Copyright © 2020 Elector.pl. All rights reserved.
//
import Foundation

public struct FileUploadInfo {
    public let name : String
    public let mime : String
    public let data: Data
    public let param: String
    
    public init(data: Data, name : String = "image.png", mime : String = "image/png", param : String = "file") {
        self.data = data
        self.name = name
        self.mime = mime
        self.param = param
    }
}
