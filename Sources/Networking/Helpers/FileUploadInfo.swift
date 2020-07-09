//
//  FileUploadInfo.swift
//  Elector
//
//  Created by Michal Ziobro on 22/02/2020.
//  Copyright © 2020 Elector.pl. All rights reserved.
//
import Foundation

public struct FileUploadInfo {
    let name : String
    let mime : String
    let data: Data
    let param: String
    
    init(data: Data, name : String = "image.png", mime : String = "image/png", param : String = "file") {
        self.data = data
        self.name = name
        self.mime = mime
        self.param = param
    }
}
