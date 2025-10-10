//
//  SettingsView.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 10/9/25.
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
            guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
                  let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
                  let clientID = dict["CLIENT_ID"] as? String else {
                //                      errorMessage = "Missing clientID"
                return
            }
            
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
            
            do {
                let result  = try await GIDSignIn.sharedInstance.signIn(
                    withPresenting: UIApplication.shared.rootViewController!,
                    hint: nil,
                    additionalScopes: [
                        "https://www.googleapis.com/auth/youtube",
                        "https://www.googleapis.com/auth/youtube.force-ssl"
                    ]
                )
                
                let user = result.user
                let accessToken = user.accessToken.tokenString
                let refreshToken = user.refreshToken.tokenString
                TokenManager.shared.saveAccessToken(accessToken)
                TokenManager.shared.saveRefreshToken(refreshToken)
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

struct SettingsView: View {
    @State var viewModel: SettingsViewModel = .init()
    var body: some View {
        VStack(spacing: 24) {
            Text("Connect Your Accounts")
                .font(.title.bold())
                .padding(.top, 40)
            
            if viewModel.isYouTubeConnected {
                HStack {
                    Text("Youtube Connected")
                        .frame(maxWidth: .infinity)
                    
                    Button(action: viewModel.disconnectYouTube) {
                        Text("Disconnect")
                    }
                }
            } else {
                Button(action: viewModel.connectYouTube) {
                    HStack {
                        Image(systemName: "play.rectangle.fill")
                            .foregroundColor(.red)
                        Text(viewModel.isConnectingGoogle ? "Connecting..." : "Connect YouTube")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                }
                .disabled(viewModel.isConnectingGoogle)
            }
            
            Button(action: viewModel.connectFacebook) {
                HStack {
                    Image(systemName: "f.circle.fill")
                        .foregroundColor(.blue)
                    Text(viewModel.isConnectingFacebook ? "Connecting..." : "Connect Facebook")
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
            .disabled(viewModel.isConnectingFacebook)
            
            if let message = viewModel.message {
                Text(message)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.top, 8)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.refresh()
        }
    }
    
    // MARK: - Google / YouTube Connection
    
   
}
