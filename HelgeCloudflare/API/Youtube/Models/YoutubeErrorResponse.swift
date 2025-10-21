//
//  YoutubeErrorResponse.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 10/21/25.
//

import Foundation

struct YoutubeErrorResponse: Codable {
    let error: ErrorResponse
    
    struct ErrorResponse: Codable {
        let code: Int
        let message: String
    }
}
