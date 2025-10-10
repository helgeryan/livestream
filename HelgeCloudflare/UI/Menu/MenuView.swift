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
