//
//  Requastable.swift
//  Elector
//
//  Created by Michal Ziobro on 22/02/2020.
//  Copyright © 2020 Elector.pl. All rights reserved.
//

import Foundation

public protocol Requestable {
    
    func asURLRequest() throws -> URLRequest
    func multipartFormData() throws -> Data?
}

public extension Requestable {
    func multipartFormData() throws -> Data? { return nil }
}
