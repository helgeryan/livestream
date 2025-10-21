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
    
    // MARK: - Properties
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
