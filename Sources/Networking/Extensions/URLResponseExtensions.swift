//
//  File.swift
//  
//
//  Created by Michal Ziobro on 19/11/2023.
//

import Foundation

extension URLResponse {
    var contentType: String? {
        (self as? HTTPURLResponse)?.allHeaderFields["Content-Type"] as? String
    }
}
