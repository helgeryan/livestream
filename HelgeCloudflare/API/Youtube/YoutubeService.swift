//
//  YoutubeService.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 9/25/25.
//

import Foundation

final class YoutubeService {
    static let shared = YoutubeService()
    
    func createBroadcast() async throws -> YoutubeBroadcastResponse {
        let action = YoutubeAPIAction.createBroadcast
        return try await APIManager.shared.sendRequest(action)
    }
    
    func createStream() async throws -> YoutubeStreamResponse {
        let action = YoutubeAPIAction.createStream
        return try await APIManager.shared.sendRequest(action)
    }
    
    func bindBroadcast(broadcastId: String, streamId: String) async throws -> YoutubeBroadcastResponse {
        let action = YoutubeAPIAction.bindBroacastToStream(broadcastId: broadcastId,
                                                           streamId: streamId)
        return try await APIManager.shared.sendRequest(action)
    }
}
