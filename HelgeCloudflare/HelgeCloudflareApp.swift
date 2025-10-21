//
//  HelgeCloudflareApp.swift
//  Helge Cloudflare
//
//  Created by Ryan Helgeson on 8/7/25.
//

import SwiftUI
import HaishinKit
import RTCHaishinKit
import RTMPHaishinKit
import SRTHaishinKit

@main
struct HelgeCloudflareApp: App {
    
    // MARK: - Initializers
    init() {
        YoutubeService.shared.start()
    }
    
    // MARK: - UI Content
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await SessionBuilderFactory.shared.register(RTMPSessionFactory())
                    await SessionBuilderFactory.shared.register(SRTSessionFactory())
                    await SessionBuilderFactory.shared.register(HTTPSessionFactory())
                }
        }
    }
}
