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
    @State var isCreatePresented: Bool = false
    

    @State var viewModel = MenuViewModel()
    
    var body: some View {
        MainNavigationView(title: "Youtube") {
            ViewModelStateView(state: viewModel.state,
                               errorRetry: viewModel.fetchLivestreams) {
                List {
                    // Channel
                    if let channel = viewModel.channel {
                        Section("Channel") {
                            HStack(alignment: .center) {
                                AsyncImage(url: URL(string: channel.snippet.thumbnails.default.url)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                                
                                Text(channel.snippet.title)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    // Broadcasts
                    Section("Broadcasts") {
                        Button {
                            isCreatePresented = true
                        } label: {
                            Label("Create", systemImage: "plus")
                        }
                        
                        ForEach(viewModel.broadcasts, id: \.id) { bc in
                            VStack(alignment: .leading) {
                                Text(bc.snippet.title)
                                    .fontWeight(.semibold)
                                
                                Text(bc.snippet.description)
                                    .fontWeight(.light)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                // destructive delete
                                Button(role: .destructive) {
                                    // optionally show confirmation
                                    viewModel.deleteBroadcast(bc)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
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
        .sheet(isPresented: $isCreatePresented) {
            EventEditorView(vm: .init()) { req in
                Task {
                    let _ = try await YoutubeService.shared.createNewLivestream(request: req)
                    viewModel.fetchLivestreams()
                }
            }
        }
    }
}
