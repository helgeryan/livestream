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
    
    func fetchLivestreams() {
        Task {
            do {
                state = .loading
                let response = try await YoutubeService.shared.fetchBroadcasts()
                broadcasts = response.items
                
                state = .loaded
            } catch let error as CustomError {
                state = .error(error)
            }
        }
    }
}
