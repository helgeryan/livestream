//
//  HKPreviewView.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 10/8/25.
//

import Foundation
import SwiftUI
import HaishinKit

struct HKPreviewView: UIViewRepresentable {
    let mixer: MediaMixer
    
    func makeUIView(context: Context) -> MTHKView {
        let view = MTHKView(frame: .zero)
        view.videoGravity = .resizeAspectFill
        Task {
            await mixer.addOutput(view)
        }
        return view
    }
    
    func updateUIView(_ uiView: MTHKView, context: Context) {}
}
