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
            
            Button {
                fetchBroadcastStatus()
            } label: {
                Text("Get Status")
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
            
            Button {
                bindBroadcast(accessToken: StreamHelper.shared.token,
                              broadcastId: StreamHelper.shared.bcId,
                              streamId: StreamHelper.shared.streamId, completion: { _ in
                    
                })
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
            scheduleYouTubeLive(accessToken: accessToken)
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
    
//    func createLiveBroadcast(accessToken: String) {
//        let url = URL(string: "https://www.googleapis.com/youtube/v3/liveBroadcasts?part=snippet,contentDetails,status")!
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let body: [String: Any] = [
//            "snippet": [
//                "title": "My iOS Livestream",
//                "scheduledStartTime": ISO8601DateFormatter().string(from: Date().addingTimeInterval(60))
//            ],
//            "status": [
//                "privacyStatus": "private"
//            ],
//            "contentDetails": [
//                "enableAutoStart": true,
//                "enableAutoStop": true
//            ]
//        ]
//
//        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
//
//        URLSession.shared.dataTask(with: request) { data, _, error in
//            if let data = data {
//                print(String(data: data, encoding: .utf8) ?? "")
//            }
//        }.resume()
//    }
    
    func scheduleYouTubeLive(accessToken: String) {
        fetchChannelID(accessToken: accessToken) { channelId, _ in
            StreamHelper.shared.channelId = channelId!
            createBroadcast(accessToken: accessToken) { broadcastId in
                guard let broadcastId = broadcastId else { return }

                print()
                self.createStream(accessToken: accessToken) { streamId, ingestUrl, streamKey in
                    guard let streamId = streamId, let ingestUrl = ingestUrl, let streamKey = streamKey else { return }

                    print()
                    self.bindBroadcast(accessToken: accessToken, broadcastId: broadcastId, streamId: streamId) { success in
                        if success {
                            print("✅ Broadcast scheduled and bound to stream!")
                            print("RTMP URL:", ingestUrl)
                            print("Stream Key:", streamKey)
                            StreamHelper.shared.streamKey = streamKey
                            StreamHelper.shared.bcId = broadcastId
                            StreamHelper.shared.streamId = streamId
                        }
                    }
                }
            }
        }
    }
    
    func bindBroadcast(accessToken: String, broadcastId: String, streamId: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "https://www.googleapis.com/youtube/v3/liveBroadcasts/bind?id=\(broadcastId)&part=status,contentDetails&streamId=\(streamId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let _ = json["id"] as? String {
                print(json)
                completion(true)
            } else {
                print("Bind response:", String(data: data, encoding: .utf8) ?? "")
                completion(false)
            }
        }.resume()
    }

    
    func createStream(accessToken: String, completion: @escaping (String?, String?, String?) -> Void) {
        let url = URL(string: "https://www.googleapis.com/youtube/v3/liveStreams?part=snippet,cdn,contentDetails")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "snippet": [
                "title": "720p"
            ],
            "cdn": [
                "resolution": "variable",
                "frameRate": "variable",
                "ingestionType": "rtmp"
            ],
            "contentDetails": [
                "isReusable": false
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, nil, nil)
                return
            }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let id = json["id"] as? String,
               let cdn = json["cdn"] as? [String: Any],
               let ingestion = cdn["ingestionInfo"] as? [String: Any],
               let address = ingestion["ingestionAddress"] as? String,
               let streamName = ingestion["streamName"] as? String {
                print(json)
                completion(id, address, streamName)
            } else {
                print("Stream response:", String(data: data, encoding: .utf8) ?? "")
                completion(nil, nil, nil)
            }
        }.resume()
    }

    
    func createBroadcast(accessToken: String, completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://www.googleapis.com/youtube/v3/liveBroadcasts?part=snippet,contentDetails,status")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let startTime = ISO8601DateFormatter().string(from: Date().addingTimeInterval(60)) // 1 hour later

        let body: [String: Any] = [
            "snippet": [
                "title": "Ryan App Broadcast",
                "description": "",
                "scheduledStartTime": startTime
            ],
            "contentDetails": [
                "monitorStream": [
                    "enableMonitorStream": false,
                    "broadcastStreamDelayMs": 60000
                ],
                "enableDvr": true,
                "enableEmbed": false,
                "enableContentEncryption": false,
                "enableLowLatency": false,
                "recordFromStart": true,
                "startWithSlate": false,
                "enableAutoStart": true,
                "enableAutoStop": false
            ],
            "status": [
                "privacyStatus": "public",
                "selfDeclaredMadeForKids": false
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let id = json["id"] as? String {
                print(json)
                completion(id)
            } else {
                print("Broadcast response:", String(data: data, encoding: .utf8) ?? "")
                completion(nil)
            }
        }.resume()
    }

    
    func fetchBroadcastStatus() {
        let urlString = "https://www.googleapis.com/youtube/v3/liveBroadcasts?part=status&id=\(StreamHelper.shared.bcId)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(StreamHelper.shared.token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error:", error)
                return
            }
            guard let data = data else {
                print("❌ No data received")
                return
            }
            do {
                let decoded = try JSONDecoder().decode(LiveBroadcastResponse.self, from: data)
                if let item = decoded.items.first {
                    print("✅ Broadcast ID: \(item.id)")
                    print("Lifecycle status: \(item.status.lifeCycleStatus)")
                } else {
                    print("⚠️ No broadcast found with ID: \(StreamHelper.shared.bcId)")
                }
            } catch {
                print("❌ JSON decode error:", error)
                if let json = String(data: data, encoding: .utf8) {
                    print("Response JSON:", json)
                }
            }
        }
        task.resume()
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

