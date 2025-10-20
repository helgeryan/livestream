//
//  YoutubeAPIAction.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 9/25/25.
//

import Foundation

enum YoutubeAPIAction: HTTPRequest {
    case getChannel(_ mine: Bool = true)
    case getBroadcasts(mine: Bool = true, maxResults: Int = 10)
    case createStream
    case createBroadcast(_ request: YoutubeCreateBroadcastRequest)
    case bindBroacastToStream(broadcastId: String,
                              streamId: String)
    case deleteBroadcast(broadcastId: String)
    
    var method: HTTPMethod {
        return switch self {
        case .createStream,
                .createBroadcast,
                .bindBroacastToStream: .post
        case .getChannel,
                .getBroadcasts: .get
        case .deleteBroadcast: .delete
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
        case .getChannel: "/youtube/v3/channels"
        case .createBroadcast, .getBroadcasts, .deleteBroadcast: "/youtube/v3/liveBroadcasts"
        case .bindBroacastToStream: "/youtube/v3/liveBroadcasts/bind"
        case .createStream: "/youtube/v3/liveStreams"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        return switch self {
        case .getChannel(let mine): [
            URLQueryItem(name: "part", value: "snippet,statistics"),
            URLQueryItem(name: "mine", value: mine)
        ]
            
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
        case .getBroadcasts(let mine, let maxResults): [
            URLQueryItem(name: "part", value: "snippet,contentDetails,status"),
            URLQueryItem(name: "mine", value: mine),
            URLQueryItem(name: "maxResults", value: maxResults)
        ]
        case .deleteBroadcast(let broadcastId): [
            URLQueryItem(name: "id", value: broadcastId)
        ]
            
        }
    }
    
    var body: Data? {
        switch self {
        case .getBroadcasts: return nil
        case .createBroadcast(let request):
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            return try? encoder.encode(request)
        case .createStream:
            return try? JSONEncoder().encode(YoutubeCreateStreamRequest())
        default:
            return nil
        }
    }
    
    var isLoggingEnabled: Bool { true }
    
    var headers: [HTTPHeader] {
        let auth = HTTPHeader(key: "Authorization",
                              value: "Bearer \(TokenManager.shared.getAccessToken()!)")
        let contentType = HTTPHeader(key: "Content-Type", value: "application/json")
        return [auth, contentType]
    }
    
    func decodeError(errorData: Data) -> Error? {
        let decoder = JSONDecoder()
        if let response = try? decoder.decode(YoutubeErrorResponse.self, from: errorData) {
            return YoutubeError.generalError(response)
        } else {
            return nil
        }
    }
}

struct YoutubeErrorResponse: Codable {
    let error: ErrorResponse
    
    struct ErrorResponse: Codable {
        let code: Int
        let message: String
    }
}

struct YoutubeCreateBroadcastRequest: Codable {
    var snippet: SnippetRequest
    var contentDetails: ContentDetailsRequest = .init()
    var status: StatusRequest = .init()
    
    init(title: String = "",
        description: String = "",
         scheduledStartTime: Date = .now,
         privacyStatus: YoutubePrivacyStatus = .public,
        isForKids: Bool = false) {
        self.snippet = SnippetRequest(
            title: title,
            description: description,
            scheduledStartTime: scheduledStartTime
        )
        self.status = StatusRequest(
            privacyStatus: privacyStatus,
            selfDeclaredMadeForKids: isForKids
        )
    }
}

struct SnippetRequest: Codable {
    var title: String
    var description: String
    var scheduledStartTime: Date
}

struct ContentDetailsRequest: Codable {
    var monitorStream: MonitorStreamRequest = .init()
    var enableDvr: Bool = true
    var enableEmbed: Bool = false
    var enableContentEncryption: Bool = false
    var enableLowLatency: Bool = false
    var recordFromStart: Bool = true
    var startWithSlate: Bool = false
    var enableAutoStart: Bool = true
    var enableAutoStop: Bool = false
}

struct MonitorStreamRequest: Codable {
    var enableMonitorStream: Bool = false
    var broadcastStreamDelayMs: Int = 60000
}

struct StatusRequest: Codable {
    var privacyStatus: YoutubePrivacyStatus = .public
    var selfDeclaredMadeForKids: Bool = false
}

struct YoutubeCreateStreamRequest: Codable {
    var snippet: StreamSnippetRequest = .init()
    var cdn: CDNRequest = .init()
    var contentDetails: StreamContentDetailsRequest = .init()
}

struct StreamSnippetRequest: Codable {
    var title: String = "720p"
}

struct CDNRequest: Codable {
    var resolution: String = "variable"
    var frameRate: String = "variable"
    var ingestionType: String = "rtmp"
}

struct StreamContentDetailsRequest: Codable {
    var isReusable: Bool = false
}
