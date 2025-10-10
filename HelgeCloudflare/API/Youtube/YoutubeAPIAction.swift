//
//  YoutubeAPIAction.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 9/25/25.
//

import Foundation

enum YoutubeAPIAction: HTTPRequest {
    case getBroadcasts
    case createStream
    case createBroadcast(_ request: YoutubeCreateBroadcastRequest)
    case bindBroacastToStream(broadcastId: String,
                              streamId: String)
    
    var method: HTTPMethod {
        return switch self {
        case .createStream,
                .createBroadcast,
                .bindBroacastToStream: .post
        case .getBroadcasts: .get
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
        case .createBroadcast, .getBroadcasts: "/youtube/v3/liveBroadcasts"
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
        case .getBroadcasts: [
            URLQueryItem(name: "part", value: "snippet,contentDetails,status"),
            URLQueryItem(name: "mine", value: "\(true)"),
            URLQueryItem(name: "maxResults", value: "10")
        ]
            
        }
    }
    
    var body: Data? {
        switch self {
        case .getBroadcasts:
            return nil
        case .createBroadcast(let request):
            let startTime = ISO8601DateFormatter().string(from: request.startTime) // 1 hour later
            
            let body: [String: Any] = [
                "snippet": [
                    "title": request.title,
                    "description": request.description,
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
                    "privacyStatus": request.privacy.rawValue,
                    "selfDeclaredMadeForKids": request.isForKids
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
                              value: "Bearer \(TokenManager.shared.getAccessToken()!)")
        let contentType = HTTPHeader(key: "Content-Type", value: "application/json")
        return [auth, contentType]
    }
}
