//
//  MenuView.swift
//  Default SwiftUI App
//
//  Created by Ryan Helgeson on 8/7/25.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct MenuView: View {
    @State private var streamKey: String?
    @State private var ingestionAddress: String?
    @State private var errorMessage: String?

    @State var viewModel = MenuViewModel()
    
    var body: some View {
        MainNavigationView(title: "Broadcasts") {
            ViewModelStateView(state: viewModel.state,
                               errorRetry: viewModel.fetchLivestreams) {
                List {
                    ForEach(viewModel.broadcasts, id: \.id) { bc in
                        VStack {
                            Text(bc.snippet.title)
                            Text(bc.snippet.description)
                        }
                    }
                }
            }
        }
        .onAppear {
            withAnimation {
                viewModel.fetchLivestreams()
            }
        }
    }
}



extension UIApplication {
    var rootViewController: UIViewController? {
        connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first
    }
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

import Foundation
import Security


final class TokenManager {
    static let shared = TokenManager()
    private init() {}
    
    private let accessTokenKey = "youtube_access_token"
    private let refreshTokenKey = "youtube_refresh_token"

    // MARK: - Public API
    func saveAccessToken(_ token: String) {
        save(token, forKey: accessTokenKey)
    }

    func saveRefreshToken(_ token: String) {
        save(token, forKey: refreshTokenKey)
    }

    func getAccessToken() -> String? {
        read(forKey: accessTokenKey)
    }

    func getRefreshToken() -> String? {
        read(forKey: refreshTokenKey)
    }

    func clearTokens() {
        delete(forKey: accessTokenKey)
        delete(forKey: refreshTokenKey)
    }

    // MARK: - Private helpers
    private func save(_ value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        // Delete existing value before adding new one
        SecItemDelete(query as CFDictionary)
        
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        SecItemAdd(attributes as CFDictionary, nil)
    }

    private func read(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataRef)

        guard status == errSecSuccess,
              let data = dataRef as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        return value
    }

    private func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
