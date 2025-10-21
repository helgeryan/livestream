//
//  SettingsViewModel.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 10/10/25.
//

import SwiftUI
import GoogleSignIn

@MainActor
@Observable class SettingsViewModel {
    var isConnectingGoogle = false
    var isYouTubeConnected: Bool = false
    var isConnectingFacebook = false
    var isFacebookConnected: Bool = false
    var message: String?
    
    init() {
        self.refresh()
    }
    
    func refresh() {
        self.isYouTubeConnected = TokenManager.shared.getAccessToken() != nil
        self.isFacebookConnected = TokenManager.shared.getAccessToken() != nil
    }
    
    func disconnectYouTube() {
        GIDSignIn.sharedInstance.signOut()
        TokenManager.shared.clearTokens()
        self.refresh()
    }
    
    func connectYouTube() {
        Task {
            do {
                try await YoutubeService.shared.signIn()
                self.refresh()
            } catch {
                //                errorMessage = "Sign-in failed: \(error.localizedDescription)"
                return
            }
        }
    }
    
    // MARK: - Facebook Connection
    func connectFacebook() {
//        let manager = LoginManager()
//        isConnectingFacebook = true
//        message = nil
//
//        manager.logIn(permissions: ["public_profile", "email"], from: nil) { result, error in
//            isConnectingFacebook = false
//            if let error = error {
//                message = "Facebook sign-in failed: \(error.localizedDescription)"
//                return
//            }
//            guard let tokenString = AccessToken.current?.tokenString else {
//                message = "No Facebook token found"
//                return
//            }
//            let credential = FacebookAuthProvider.credential(withAccessToken: tokenString)
//            Auth.auth().signIn(with: credential) { authResult, error in
//                if let error = error {
//                    message = "Firebase auth failed: \(error.localizedDescription)"
//                } else {
//                    message = "Facebook account connected!"
//                }
//            }
//        }
    }
}
