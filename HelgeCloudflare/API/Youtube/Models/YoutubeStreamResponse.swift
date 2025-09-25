//
//  YoutubeStreamResponse.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 9/25/25.
//

struct YoutubeStreamResponse: Codable {
    var id: String
    var cdn: YoutubeCDNResponse
}

struct YoutubeCDNResponse: Codable {
    var ingestionInfo: YoutubeIngestionResponse
}

struct YoutubeIngestionResponse: Codable {
    var ingestionAddress: String
    var streamName: String
}
