//
//  YoutubePrivacyStatus.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 10/21/25.
//

import Foundation

enum YoutubePrivacyStatus: String, CaseIterable, Identifiable, Codable {
    case `public` = "public"
    case unlisted = "unlisted"
    case `private` = "private"

    var id: String { rawValue }
    
    var text: String {
        return switch self {
        case .public: "Public"
        case .unlisted:  "Unlisted"
        case .private: "Private"
        }
    }
}
