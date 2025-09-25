//
//  YoutubeAPIAction.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 9/25/25.
//

import Foundation

enum YoutubeAPIAction: HTTPRequest {
    case createStream
    case createBroadcast
    case bindBroacastToStream(broadcastId: String,
                              streamId: String)
    
    var method: HTTPMethod {
        return switch self {
        case .createStream,
                .createBroadcast,
                .bindBroacastToStream: .post
        }
    }
    
    var host: String {
        return "www.googleapis.com"
    }
    
    var scheme: URLScheme {
        return .https
    }
    
    var path: String {
        return switch self {
        case .createBroadcast: "/youtube/v3/liveBroadcasts"
        case .bindBroacastToStream: "/youtube/v3/liveBroadcasts/bind"
        case .createStream: "/youtube/v3/liveStreams"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        return switch self {
        case .createBroadcast: [
            URLQueryItem(name: "part", value: "snippet,contentDetails,status")
        ]
        case .createStream: [
            URLQueryItem(name: "part", value: "snippet,contentDetails,cdn")
        ]
        case .bindBroacastToStream(let broadcastId, let streamId): [
            URLQueryItem(name: "part", value: "snippet,contentDetails,status"),
            URLQueryItem(name: "id", value: broadcastId),
            URLQueryItem(name: "streamId", value: streamId)
        ]
            
        }
    }
    
    var body: Data? {
        switch self {
        case .createBroadcast:
            let startTime = ISO8601DateFormatter().string(from: Date().addingTimeInterval(60)) // 1 hour later
            
            let body: [String: Any] = [
                "snippet": [
                    "title": "Ryan App Broadcast",
                    "description": "",
                    "scheduledStartTime": startTime
                ],
                "contentDetails": [
                    "monitorStream": [
                        "enableMonitorStream": false,
                        "broadcastStreamDelayMs": 60000
                    ],
                    "enableDvr": true,
                    "enableEmbed": false,
                    "enableContentEncryption": false,
                    "enableLowLatency": false,
                    "recordFromStart": true,
                    "startWithSlate": false,
                    "enableAutoStart": true,
                    "enableAutoStop": false
                ],
                "status": [
                    "privacyStatus": "public",
                    "selfDeclaredMadeForKids": false
                ]
            ]
            
            return try? JSONSerialization.data(withJSONObject: body)
        case .createStream:
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
            
        default:
            return nil
        }
    }
    
    var headers: [HTTPHeader] {
        let auth = HTTPHeader(key: "Authorization",
                              value: "Bearer \(StreamHelper.shared.token)")
        let contentType = HTTPHeader(key: "Content-Type", value: "application/json")
        return [auth, contentType]
    }
}
