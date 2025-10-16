//
//  YoutubeBroadcastResponse.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 9/25/25.
//

struct YoutubeBroadcastResponse: Codable {
    var kind: String
    var etag: String
    var id: String
    var snippet: YoutubeSnippet
    var status: YoutubeBroadcastStatus
}

struct YoutubeSnippet: Codable {
    let title: String
    let description: String
    let scheduledStartTime: String?
}

struct YoutubeBroadcastStatus: Codable {
    let lifeCycleStatus: String?
    let privacyStatus: String?
}

struct LiveBroadcastResponse: Codable {
    let items: [YoutubeBroadcastResponse]
}

struct YouTubeChannelResponse: Codable {
    let items: [ChannelItem]
}

struct ChannelItem: Codable {
    let id: String
}
