//
//  Extension+URLQueryItem.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 10/20/25.
//

import Foundation

extension URLQueryItem {
    init(name: String, value: Bool) {
        self.init(name: name, value: "\(value)")
    }
    
    init(name: String, value: Int) {
        self.init(name: name, value: "\(value)")
    }
}
