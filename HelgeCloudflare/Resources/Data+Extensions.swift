//
//  Data+Extensions.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 10/16/25.
//

import Foundation

extension Data {
    var prettyJSONString: String? {
        // Try to parse the data into a Foundation object (Dictionary/Array)
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let prettyData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return nil
        }
        return prettyString
    }
}
