//
//  MenuViewModel.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 9/25/25.
//

import Foundation

@MainActor
@Observable class MenuViewModel {
    var state: ViewModelState = .loaded
    var broadcasts: [YoutubeBroadcastResponse] = []
    var channel: YoutubeChannelResponse.Channel? = nil
    
    func fetchLivestreams() {
        Task {
            do {
                state = .loading
                let broadcastsResponse = try await YoutubeService.shared.fetchBroadcasts()
                let channelResponse = try await YoutubeService.shared.fetchChannels()
                broadcasts = broadcastsResponse.items
                channel = channelResponse.items.first
                
                state = .loaded
            } catch let error as CustomError {
                state = .error(error)
            }
        }
    }
    
    func deleteBroadcast(_ broadcast: YoutubeBroadcastResponse) {
        Task {
            do {
                try await YoutubeService.shared.deleteBroadcast(broadcastId: broadcast.id)
                broadcasts.removeAll { $0.id == broadcast.id }
            } catch {
                print("Error deleting broadcast: \(error)")
            }
        }
    }
}
