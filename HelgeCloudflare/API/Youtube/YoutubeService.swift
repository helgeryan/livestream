//
//  YoutubeService.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 9/25/25.
//

import SwiftUI
import GoogleSignIn

enum YoutubeError: CustomError {
    case noClientID
    case noAccessToken
    case generalError(YoutubeErrorResponse)
    
    
    var title: LocalizedStringKey? {
        return switch self {
        case .noClientID, .noAccessToken: "Youtube Authentication Failed"
        case .generalError: "Youtube Connection Failed"
        }
    }
    
    var userMessage: LocalizedStringKey {
        return switch self {
        case .noClientID: "No client ID, please contact support to resolve the issue."
        case .noAccessToken: "Access has expired, please sign in again."
        case .generalError(let response): LocalizedStringKey(response.error.message)
        }
    }
}

struct YoutubeCreateBroadcastRequest: Identifiable {
    let id = UUID()
    var title: String = ""
    var description: String = ""
    var startTime: Date = Date()
    var privacy: YoutubePrivacyStatus = .public
    var isForKids: Bool = false
}

enum YoutubePrivacyStatus: String, CaseIterable, Identifiable {
    case `public` = "public"
    case unlisted = "unlisted"
    case `private` = "private"

    var id: String { rawValue }
}

final class YoutubeService {
    static let shared = YoutubeService()
    
    // MARK: - Authentication
    private func getClientID() throws -> String {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let clientID = dict["CLIENT_ID"] as? String else {
            throw YoutubeError.noClientID
        }
        return clientID
    }
    
    @MainActor
    func signIn() async throws {
        let clientID = try getClientID()
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        
        let presentingVc = UIApplication.shared.rootViewController!
        let scopes = [
            "https://www.googleapis.com/auth/youtube",
            "https://www.googleapis.com/auth/youtube.force-ssl"
        ]
        do {
            let result  = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingVc,
                                                                    hint: nil,
                                                                    additionalScopes: scopes)
            let user = result.user
            TokenManager.shared.saveAccessToken(user.accessToken.tokenString)
            TokenManager.shared.saveRefreshToken(user.refreshToken.tokenString)
        } catch {
            throw error
        }
    }
    
    private func verifyToken() throws {
        if TokenManager.shared.getAccessToken() == nil {
            throw YoutubeError.noAccessToken
        }
    }
    
    func refreshToken() async throws {
        let user = try await GIDSignIn.sharedInstance.restorePreviousSignIn()
        TokenManager.shared.saveAccessToken(user.accessToken.tokenString)
        TokenManager.shared.saveRefreshToken(user.refreshToken.tokenString)
    }
    
    // MARK: - Broadcasts/Livestreaming
    func createNewLivestream(request: YoutubeCreateBroadcastRequest) async throws {
        try verifyToken()
        
        let broadcast = try await createBroadcast(request: request)
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
    
    func fetchChannels(mine: Bool = true) async throws -> YoutubeChannelResponse {
        let action = YoutubeAPIAction.getChannel(mine)
        return try await APIManager.shared.sendRequest(action)
    }
    
    func fetchBroadcasts(mine: Bool = true, maxResults: Int = 10) async throws -> LiveBroadcastResponse {
        let action = YoutubeAPIAction.getBroadcasts(mine: mine, maxResults: maxResults)
        return try await APIManager.shared.sendRequest(action)
    }
    
    func createBroadcast(request: YoutubeCreateBroadcastRequest) async throws -> YoutubeBroadcastResponse {
        let action = YoutubeAPIAction.createBroadcast(request)
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
    
    func deleteBroadcast(broadcastId: String) async throws {
        let action = YoutubeAPIAction.deleteBroadcast(broadcastId: broadcastId)
        try await APIManager.shared.sendRequest(action)
    }
}

struct YoutubeChannelResponse: Codable {
    struct Channel: Codable {
        let id: String
        let snippet: Snippet
        let statistics: Statistics
    }
    
    struct Snippet: Codable {
        let title: String
        let description: String
        let thumbnails: YoutubeThumbnails
    }
    
    struct YoutubeThumbnails: Codable {
        let `default`: Thumbnail
        let high: Thumbnail
        let medium: Thumbnail
        
        struct Thumbnail: Codable {
            let url: String
        }
    }
    
    struct Statistics: Codable {
        let viewCount: String
        let subscriberCount: String
        let videoCount: String
    }
    
    let items: [Channel]
}
