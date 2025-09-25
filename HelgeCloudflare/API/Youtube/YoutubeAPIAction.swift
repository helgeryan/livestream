//
//  YoutubeAPIAction.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 9/25/25.
//

import Foundation

enum YoutubeAPIAction: HTTPRequest {
    case createStream
    
    var method: HTTPMethod {
        return switch self {
            case .createStream: .post
        }
    }
    
    var host: String {
        return switch self {
        case .createStream: "www.googleapis.com"
        }
    }
    
    var scheme: URLScheme {
        return switch self {
        case .createStream: .https
        }
    }
    
    var path: String {
        return switch self {
        case .createStream: "/youtube/v3/liveStreams"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        return switch self {
        case .createStream: [
            URLQueryItem(name: "part", value: "snippet,contentDetails,cdn")
        ]
            
        }
    }
    
    var body: Data? {
        switch self {
        case .createStream:
            let startTime = ISO8601DateFormatter().string(from: Date().addingTimeInterval(60)) // 1 hour later
            
            let body: [String: Any] = [
                "snippet": [
                    "title": "720p"
                ],
                "cdn": [
                    "resolution": "variable",
                    "frameRate": "variable",
                    "ingestionType": "rtmp"
                ],
                "contentDetails": [
                    "isReusable": false
                ]
            ]
            return try? JSONSerialization.data(withJSONObject: body)
        }
    }
    
    var headers: [HTTPHeader] {
        let auth = HTTPHeader(key: "Authorization",
                              value: "Bearer \(StreamHelper.shared.token)")
        let contentType = HTTPHeader(key: "Content-Type", value: "application/json")
        return [auth, contentType]
    }
}
