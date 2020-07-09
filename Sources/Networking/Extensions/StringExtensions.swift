//
//  File.swift
//  
//
//  Created by Michal Ziobro on 09/07/2020.
//

import Foundation

extension String {
    
    func asURL() throws -> URL {
        
        if let url = URL(string: self) {
            return url
        }
        
        throw URLError(.unknown)
    }
}
