//
//  EncodableExtensions.swift
//  Default SwiftUI App
//
//  Created by Ryan Helgeson on 9/17/25.
//

import Foundation

extension Encodable {
    func queryItems() -> [URLQueryItem] {
        let encoder = JSONEncoder()
        
        // Convert to Dictionary using JSON + decoding
        guard let data = try? encoder.encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return []
        }
        
        // Map dictionary to query items
        return dictionary.compactMap { key, value in
            if let array = value as? [Any] {
                // Flatten arrays into multiple items with same key
                return array.compactMap {
                    URLQueryItem(name: key, value: "\($0)")
                }
            } else {
                return [URLQueryItem(name: key, value: "\(value)")]
            }
        }.flatMap { $0 }
    }
}
