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
    var channelId: String = ""
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

@MainActor
final class LiveStreamViewModel: ObservableObject {
    @Published var currentFPS: FPS = .fps30
    @Published var visualEffectItem: VideoEffectItem = .none
    @Published private(set) var error: Error?
    @Published var isShowError = false
    @Published private(set) var isTorchEnabled = false
    @Published private(set) var readyState: SessionReadyState = .closed
    private(set) var mixer = MediaMixer(captureSessionMode: .multi)
    private var tasks: [Task<Void, Swift.Error>] = []
    private var session: (any Session)?
    private var currentPosition: AVCaptureDevice.Position = .back
    @ScreenActor private var videoScreenObject: VideoTrackScreenObject?
    @ScreenActor private var currentVideoEffect: VideoEffect?

    init() {
        Task { @ScreenActor in
            videoScreenObject = VideoTrackScreenObject()
        }
    }

    func startPublishing() {
        Task {
            guard let session else {
                return
            }
            do {
                try await session.connect {
                    Task { @MainActor in
                        self.isShowError = true
                    }
                }
            } catch {
                self.error = error
                self.isShowError = true
//                logger.error(error)
            }
        }
    }

    func stopPublishing() {
        Task {
            do {
                try await session?.close()
            } catch {
//                logger.error(error)
            }
        }
    }

    func makeSession(preference: PreferenceViewModel) async {
        // Make session.
        do {
            session = try await SessionBuilderFactory
                .shared
                .make(preference.makeURL())
                .setMethod(.ingest)
                .build()
            guard let session else {
                return
            }
            await mixer.addOutput(session.stream)
            tasks.append(Task {
                for await readyState in await session.readyState {
                    self.readyState = readyState
                }
            })
        } catch {
            self.error = error
            isShowError = true
        }
        do {
            if let session {
                try await session.stream.setAudioSettings(preference.makeAudioCodecSettings(session.stream.audioSettings))
            }
        } catch {
            self.error = error
            isShowError = true
        }
        do {
            if let session {
                try await session.stream.setVideoSettings(preference.makeVideoCodecSettings(session.stream.videoSettings))
            }
        } catch {
            self.error = error
            isShowError = true
        }
    }

    func startRunning(preference: PreferenceViewModel) {
        Task {
            // SetUp a mixer.
            var videoMixerSettings = await mixer.videoMixerSettings
            videoMixerSettings.mode = .offscreen
            await mixer.setVideoMixerSettings(videoMixerSettings)
            // Attach devices
            let back = AVCaptureDevice.default(for: .video)
            try? await mixer.attachVideo(back, track: 0)
            let audio = AVCaptureDevice.default(for: .audio)
            try? await mixer.attachAudio(audio, track: 0)
            await mixer.startRunning()
            await makeSession(preference: preference)
        }
        Task { @ScreenActor in
            guard let videoScreenObject else {
                return
            }
            videoScreenObject.cornerRadius = 16.0
            videoScreenObject.track = 1
            videoScreenObject.horizontalAlignment = .right
            videoScreenObject.layoutMargin = .init(top: 16, left: 0, bottom: 0, right: 16)
            videoScreenObject.size = .init(width: 160 * 2, height: 90 * 2)
            await mixer.screen.size = .init(width: 720, height: 1080)
//            await mixer.screen.backgroundColor = NSColor.black.cgColor
            try? await mixer.screen.addChild(videoScreenObject)
        }
    }

    func stopRunning() {
        Task {
            await mixer.stopRunning()
            try? await mixer.attachAudio(nil)
            try? await mixer.attachVideo(nil, track: 0)
            try? await mixer.attachVideo(nil, track: 1)
            if let session {
                await mixer.removeOutput(session.stream)
            }
            tasks.forEach { $0.cancel() }
            tasks.removeAll()
        }
    }

    func flipCamera() {
        Task {
            var videoMixerSettings = await mixer.videoMixerSettings
            if videoMixerSettings.mainTrack == 0 {
                videoMixerSettings.mainTrack = 1
                await mixer.setVideoMixerSettings(videoMixerSettings)
                Task { @ScreenActor in
                    videoScreenObject?.track = 0
                }
            } else {
                videoMixerSettings.mainTrack = 0
                await mixer.setVideoMixerSettings(videoMixerSettings)
                Task { @ScreenActor in
                    videoScreenObject?.track = 1
                }
            }
        }
    }

    func setVisualEffet(_ videoEffect: VideoEffectItem) {
        Task { @ScreenActor in
            if let currentVideoEffect {
                _ = await mixer.screen.unregisterVideoEffect(currentVideoEffect)
            }
            if let videoEffect = videoEffect.makeVideoEffect() {
                currentVideoEffect = videoEffect
                _ = await mixer.screen.registerVideoEffect(videoEffect)
            }
        }
    }

    func toggleTorch() {
        Task {
            await mixer.setTorchEnabled(!isTorchEnabled)
            isTorchEnabled.toggle()
        }
    }

    func setFrameRate(_ fps: Float64) {
        Task {
            do {
                // Sets to input frameRate.
                try? await mixer.configuration(video: 0) { video in
                    do {
                        try video.setFrameRate(fps)
                    } catch {
//                        logger.error(error)
                    }
                }
                try? await mixer.configuration(video: 1) { video in
                    do {
                        try video.setFrameRate(fps)
                    } catch {
//                        logger.error(error)
                    }
                }
                // Sets to output frameRate.
                try await mixer.setFrameRate(fps)
            } catch {
//                logger.error(error)
            }
        }
    }
}

extension LiveStreamViewModel: MTHKViewRepresentable.PreviewSource {
    nonisolated func connect(to view: HaishinKit.MTHKView) {
        Task {
            await mixer.addOutput(view)
        }
    }
}


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
        switch self {
        case .fps15:
            return 15
        case .fps30:
            return 30
        case .fps60:
            return 60
        }
    }

    var id: Self { self }
}

enum VideoEffectItem: String, CaseIterable, Identifiable, Sendable {
    case none
    case monochrome

    var id: Self { self }

    func makeVideoEffect() -> VideoEffect? {
        switch self {
        case .none:
            return nil
        case .monochrome:
            return MonochromeEffect()
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
