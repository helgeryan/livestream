//
//  AccountView.swift
//  Default SwiftUI App
//
//  Created by Ryan Helgeson on 8/7/25.
//

import SwiftUI
import AVFoundation
import HaishinKit
import RTCHaishinKit
import VideoToolbox

final class StreamHelper {
    static let shared: StreamHelper = .init()
    
    var streamKey: String = ""
    var bcId: String = ""
    var token: String = ""
    var streamId: String = ""
}

struct AccountView: View {
    @StateObject var viewModel: LiveStreamViewModel = .init()
    var preference: PreferenceViewModel = .init()
    
    var body: some View {
        VStack {
            // Camera preview
            HKPreviewView(mixer: viewModel.mixer)
                .frame(width: 300, height: 300)
                .background(.black)
            
            Spacer()
            HStack {
                Button(action: {
                    viewModel.startPublishing()
                }) {
                    Text("Start Stream")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    viewModel.stopPublishing()
                }) {
                    Text("Stop Stream")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.startRunning(preference: preference)
        }
        .onDisappear {
            viewModel.stopRunning()
        }
    }
}

#Preview {
    AccountView()
}



extension LiveStreamViewModel: MTHKViewRepresentable.PreviewSource {
    nonisolated func connect(to view: HaishinKit.MTHKView) {
        Task {
            await mixer.addOutput(view)
        }
    }
}
