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
        .padding()
    }

    func handleSignIn() {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
                  let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
                  let clientID = dict["CLIENT_ID"] as? String else {
                      errorMessage = "Missing clientID"
                      return
                  }
        

        let scopes = [
            "https://www.googleapis.com/auth/youtube",
            "https://www.googleapis.com/auth/youtube.force-ssl"
        ]
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(
            withPresenting: UIApplication.shared.rootViewController!,
            hint: nil,
            additionalScopes: scopes
        ) { result, error in
            if let error = error {
                errorMessage = "Sign-in failed: \(error.localizedDescription)"
                return
            }
            guard let user = result?.user else { return }
            let accessToken = user.accessToken.tokenString
            // Save refresh token if available
            let refreshToken = user.refreshToken
            UserDefaults.standard.set(refreshToken, forKey: "google_refresh_token")
            createYouTubeStream(accessToken: accessToken)
        }
    }

    func createYouTubeStream(accessToken: String) {
        guard let url = URL(string: "https://www.googleapis.com/youtube/v3/liveStreams?part=snippet,cdn") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "snippet": ["title": "Swift App Live Stream"],
            "cdn": [
                "format": "1080p",
                "ingestionType": "rtmp"
            ]
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                errorMessage = "Network error: \(error.localizedDescription)"
                return
            }

            guard let data = data else { return }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let cdn = (json["cdn"] as? [String: Any]),
               let ingestionInfo = cdn["ingestionInfo"] as? [String: Any],
               let addr = ingestionInfo["ingestionAddress"] as? String,
               let key = ingestionInfo["streamName"] as? String {
                DispatchQueue.main.async {
                    ingestionAddress = addr
                    streamKey = key
                }
            } else {
                errorMessage = "Could not parse YouTube response"
            }
        }.resume()
    }
}

extension UIApplication {
    var rootViewController: UIViewController? {
        connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first
    }
}
