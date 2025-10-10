//
//  SettingsView.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 10/9/25.
//

import SwiftUI
import GoogleSignIn

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
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
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
}
