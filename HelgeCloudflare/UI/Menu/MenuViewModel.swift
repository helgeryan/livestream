//
//  MenuViewModel.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 9/25/25.
//

import Foundation

@Observable
class MenuViewModel {
    func scheduleYouTubeLive(accessToken: String) {
        Task {
            do {
                let broadcast = try await YoutubeService.shared.createBroadcast()
                let stream = try await YoutubeService.shared.createStream()
                
                print()
                
                let newBroadcast = try await YoutubeService.shared.bindBroadcast(broadcastId: broadcast.id,
                                                                                 streamId: stream.id)
                
                print("✅ Broadcast scheduled and bound to stream!")
                print("RTMP URL:", stream.cdn.ingestionInfo.ingestionAddress)
                print("Stream Key:", stream.cdn.ingestionInfo.streamName)
                StreamHelper.shared.streamKey = stream.cdn.ingestionInfo.streamName
                StreamHelper.shared.bcId = broadcast.id
                StreamHelper.shared.streamId = stream.id
            } catch {
                print(error)
            }
        }
    }
}
