//
//  NetworkError.swift
//  Elector
//
//  Created by Michal Ziobro on 22/02/2020.
//  Copyright © 2020 Elector.pl. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    
    case decoding(message: String)
    case parameterEncodingFailed(message: String)
    case network(message: String)
    case api(error: ApiError)
}

// MARK: - Identifiable
extension NetworkError : Identifiable {
    
  var id: UUID {
       return UUID()
   }
}

// MARK: - Describable Error
protocol DescribableError {
    
    var errorMessage: String? { get }
}

extension NetworkError : DescribableError {
    
    var errorMessage: String? {
        switch self {
        case .api(let apiError):
            return apiError.error
        case .network(let message):
            return message
        default:
            return nil
        }
    }
}

// MARK: - API Error
struct ApiError : Decodable {
    let error: String
    
    enum CodingKeys: String, CodingKey {
        case error = "message"
    }
}
