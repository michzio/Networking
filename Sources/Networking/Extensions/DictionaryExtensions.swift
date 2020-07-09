//
//  DictionaryExtensions.swift
//  Elector
//
//  Created by Michal Ziobro on 14/03/2020.
//  Copyright © 2020 Elector.pl. All rights reserved.
//

import Foundation

extension Dictionary {
    func merge(dict: [Key: Value]) -> Dictionary {
        var current = self
        for (k, v) in dict {
            current.updateValue(v, forKey: k)
        }
        return current
    }
}

func +<K, V>(left: Dictionary<K, V>, right: Dictionary<K, V>) -> Dictionary<K, V>  where K: Hashable, V: Any{
    left.merge(dict: right)
}

extension Dictionary {
    
    var queryString: String {
        return self.map { "\($0.key)=\($0.value)" }
                .joined(separator: "&")
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
}
