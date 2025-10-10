//
//  MenuViewModel.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 9/25/25.
//

import Foundation

@MainActor
@Observable class MenuViewModel {
    var broadcasts: [YoutubeBroadcastResponse] = []
    
    func fetchLivestreams() {
        Task {
            let response = try await YoutubeService.shared.fetchBroadcasts()
            broadcasts = response.items
        }
    }
}
