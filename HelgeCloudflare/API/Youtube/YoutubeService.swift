//
//  YoutubeService.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 9/25/25.
//

import Foundation

final class YoutubeService {
    static let shared = YoutubeService()
    
    func createNewLivestream() async throws {
        let broadcast = try await createBroadcast()
        let stream = try await createStream()
        
        print()
        
        let newBroadcast = try await bindBroadcast(broadcastId: broadcast.id,
                                                   streamId: stream.id)
        
        print("✅ Broadcast scheduled and bound to stream!")
        print("RTMP URL:", stream.cdn.ingestionInfo.ingestionAddress)
        print("Stream Key:", stream.cdn.ingestionInfo.streamName)
        StreamHelper.shared.streamKey = stream.cdn.ingestionInfo.streamName
        StreamHelper.shared.bcId = newBroadcast.id
        StreamHelper.shared.streamId = stream.id
    }
    
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
