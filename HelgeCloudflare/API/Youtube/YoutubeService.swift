//
//  YoutubeService.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 9/25/25.
//

import Foundation

final class YoutubeService {
    static let shared = YoutubeService()
    
    func createStream() async throws -> YoutubeStreamResponse {
        let action = YoutubeAPIAction.createStream
        return try await APIManager.shared.sendRequest(action)
    }
}
