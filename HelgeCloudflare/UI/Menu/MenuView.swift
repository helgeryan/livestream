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
        VStack(spacing: 20) {
            GoogleSignInButton(action: handleSignIn)
                .frame(width: 220, height: 50)

            if let key = streamKey, let address = ingestionAddress {
                Text("RTMP URL: \(address)")
                Text("Stream Key: \(key)")
            }
            
            if let err = errorMessage {
                Text("Error: \(err)")
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            GIDSignIn.sharedInstance.signOut()
        }
        .padding()
    }

    func handleSignIn() {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
                  let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
                  let clientID = dict["CLIENT_ID"] as? String else {
                      errorMessage = "Missing clientID"
                      return
                  }
    
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(
            withPresenting: UIApplication.shared.rootViewController!,
            hint: nil,
            additionalScopes: [
                "https://www.googleapis.com/auth/youtube",
                "https://www.googleapis.com/auth/youtube.force-ssl"
            ]
        ) { result, error in
            if let error = error {
                errorMessage = "Sign-in failed: \(error.localizedDescription)"
                return
            }
            guard let user = result?.user else { return }
            let accessToken = user.accessToken.tokenString
            let refreshToken = user.refreshToken.tokenString
            TokenManager.shared.saveAccessToken(accessToken)
            TokenManager.shared.saveRefreshToken(refreshToken)
            viewModel.scheduleYouTubeLive()
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
    struct Item: Codable {
        struct Status: Codable {
            let lifeCycleStatus: String
        }
        let id: String
        let status: Status
    }
    let items: [Item]
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
