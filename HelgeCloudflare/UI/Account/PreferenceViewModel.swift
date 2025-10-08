//
//  PreferenceViewModel.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 10/8/25.
//

import Foundation
import SwiftUI
import HaishinKit
import VideoToolbox

@MainActor
final class PreferenceViewModel: ObservableObject {
    @Published var showPublishSheet: Bool = false

    var uri = Preference.default.uri
    var streamName = Preference.default.streamName

    private(set) var bitRateModes: [VideoCodecSettings.BitRateMode] = [.average]

    // MARK: - AudioCodecSettings.
    @Published var audioFormat: AudioCodecSettings.Format = .aac

    // MARK: - VideoCodecSettings.
    @Published var bitRateMode: VideoCodecSettings.BitRateMode = .average
    var isLowLatencyRateControlEnabled: Bool = false

    init() {
        if #available(iOS 16.0, *) {
            bitRateModes.append(.constant)
        }
    }

    func makeVideoCodecSettings(_ settings: VideoCodecSettings) -> VideoCodecSettings {
        var newSettings = settings
        newSettings.bitRateMode = bitRateMode
        newSettings.isLowLatencyRateControlEnabled = isLowLatencyRateControlEnabled
        return newSettings
    }

    func makeAudioCodecSettings(_ settings: AudioCodecSettings) -> AudioCodecSettings {
        var newSettings = settings
        newSettings.format = audioFormat
        return newSettings
    }

    func makeURL() -> URL? {
        if uri.contains("rtmp://") {
            print(StreamHelper.shared.streamKey)
            if StreamHelper.shared.streamKey.isEmpty {
                return URL(string: uri + "/" + streamName)
            } else {
                return URL(string: uri + "/" + StreamHelper.shared.streamKey)
            }
        }
        return URL(string: uri)
    }
}

import Foundation

struct Preference: Sendable {
    // Temp
    static nonisolated(unsafe) var `default` = Preference()

    // var uri = "http://192.168.1.14:1985/rtc/v1/whip/?app=live&stream=livestream"
    var uri = "rtmp://a.rtmp.youtube.com/live2"
    var streamName = "28fx-sums-bkx5-rv0m-0hr2"

    func makeURL() -> URL? {
        if uri.contains("rtmp://") {
            print(StreamHelper.shared.streamKey)
            if StreamHelper.shared.streamKey.isEmpty {
                return URL(string: uri + "/" + streamName)
            } else {
                return URL(string: uri + "/" + StreamHelper.shared.streamKey)
            }
        }
        return URL(string: uri)
    }
}


enum FPS: String, CaseIterable, Identifiable {
    case fps15 = "15"
    case fps30 = "30"
    case fps60 = "60"

    var frameRate: Float64 {
        return switch self {
        case .fps15:  15
        case .fps30: 30
        case .fps60: 60
        }
    }

    var id: Self { self }
}

enum VideoEffectItem: String, CaseIterable, Identifiable, Sendable {
    case none
    case monochrome

    var id: Self { self }

    func makeVideoEffect() -> VideoEffect? {
        return switch self {
        case .none:  nil
        case .monochrome: MonochromeEffect()
        }
    }
}

import CoreImage
final class MonochromeEffect: VideoEffect {
    let filter: CIFilter? = CIFilter(name: "CIColorMonochrome")

    func execute(_ image: CIImage) -> CIImage {
        guard let filter: CIFilter = filter else {
            return image
        }
        filter.setValue(image, forKey: "inputImage")
        filter.setValue(CIColor(red: 0.75, green: 0.75, blue: 0.75), forKey: "inputColor")
        filter.setValue(1.0, forKey: "inputIntensity")
        return filter.outputImage!
    }
}
