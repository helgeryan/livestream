//
//  Data+Extensions.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 10/16/25.
//

import Foundation

extension Data {
    func prettyPrint() {
        // Try to parse the data into a Foundation object (Dictionary/Array)
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []) as? [String: Any] else {
            return
        }
        print(object)
    }
}
