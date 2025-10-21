//
//  YoutubeRequest.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 10/21/25.
//

import Foundation

struct YoutubeCreateBroadcastRequest: Codable {
    var snippet: SnippetRequest
    var contentDetails: ContentDetailsRequest = .init()
    var status: StatusRequest = .init()
    
    init(title: String = "",
        description: String = "",
         scheduledStartTime: Date = .now,
         privacyStatus: YoutubePrivacyStatus = .public,
        isForKids: Bool = false) {
        self.snippet = SnippetRequest(
            title: title,
            description: description,
            scheduledStartTime: scheduledStartTime
        )
        self.status = StatusRequest(
            privacyStatus: privacyStatus,
            selfDeclaredMadeForKids: isForKids
        )
    }
}

struct SnippetRequest: Codable {
    var title: String
    var description: String
    var scheduledStartTime: Date
}

struct ContentDetailsRequest: Codable {
    var monitorStream: MonitorStreamRequest = .init()
    var enableDvr: Bool = true
    var enableEmbed: Bool = false
    var enableContentEncryption: Bool = false
    var enableLowLatency: Bool = false
    var recordFromStart: Bool = true
    var startWithSlate: Bool = false
    var enableAutoStart: Bool = true
    var enableAutoStop: Bool = false
}

struct MonitorStreamRequest: Codable {
    var enableMonitorStream: Bool = false
    var broadcastStreamDelayMs: Int = 60000
}

struct StatusRequest: Codable {
    var privacyStatus: YoutubePrivacyStatus = .public
    var selfDeclaredMadeForKids: Bool = false
}

struct YoutubeCreateStreamRequest: Codable {
    var snippet: StreamSnippetRequest = .init()
    var cdn: CDNRequest = .init()
    var contentDetails: StreamContentDetailsRequest = .init()
}

struct StreamSnippetRequest: Codable {
    var title: String = "720p"
}

struct CDNRequest: Codable {
    var resolution: String = "variable"
    var frameRate: String = "variable"
    var ingestionType: String = "rtmp"
}

struct StreamContentDetailsRequest: Codable {
    var isReusable: Bool = false
}
