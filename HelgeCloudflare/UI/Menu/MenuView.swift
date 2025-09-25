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
            
            Button {
                listLiveStreams()
            } label: {
                Text("Get Stream")
            }
            
            Button {
                listLiveBroadcasts()
            } label: {
                Text("Get broadcast")
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
            StreamHelper.shared.token = accessToken
            // Save refresh token if available
            let refreshToken = user.refreshToken
            UserDefaults.standard.set(refreshToken.tokenString, forKey: "google_refresh_token")
            viewModel.scheduleYouTubeLive(accessToken: accessToken)
        }
    }
    
    func listLiveStreams() {
        let urlString = "https://www.googleapis.com/youtube/v3/liveStreams?part=id,snippet,cdn,status&id=\(StreamHelper.shared.streamId)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(StreamHelper.shared.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Streams error:", error)
                return
            }
            guard let data = data else {
                print("❌ No data received for streams")
                return
            }
            if let json = String(data: data, encoding: .utf8) {
                print("📡 Streams response:\n\(json)")
            }
        }.resume()
    }
    
    func fetchChannelID(accessToken: String, completion: @escaping (String?, Error?) -> Void) {
        // Build request
        var request = URLRequest(url: URL(string: "https://www.googleapis.com/youtube/v3/channels?part=id&mine=true")!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        // Perform request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "YouTubeAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(YouTubeChannelResponse.self, from: data)
                if let channelId = decoded.items.first?.id {
                    completion(channelId, nil)
                } else {
                    completion(nil, NSError(domain: "YouTubeAPI", code: -2, userInfo: [NSLocalizedDescriptionKey: "No channel ID found"]))
                }
            } catch {
                completion(nil, error)
            }
        }.resume()
    }

    
    func listLiveBroadcasts() {
        let urlString = "https://www.googleapis.com/youtube/v3/liveBroadcasts?part=id,snippet,status,contentDetails&id=\(StreamHelper.shared.bcId)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(StreamHelper.shared.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Broadcasts error:", error)
                return
            }
            guard let data = data else {
                print("❌ No data received for broadcasts")
                return
            }
            if let json = String(data: data, encoding: .utf8) {
                print("📺 Broadcasts response:\n\(json)")
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

