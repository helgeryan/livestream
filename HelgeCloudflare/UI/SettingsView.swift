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
    
    @State var isCreatePresented: Bool = false
    
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
            
            Button {
                isCreatePresented = true
            } label: {
                Text("Create New Livestream")
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.refresh()
        }
        .sheet(isPresented: $isCreatePresented) {
            EventEditorView(vm: .init()) { req in
                Task {
                    let _ = try await YoutubeService.shared.createNewLivestream(request: req)
                }
            }
        }
    }
}


import Combine

// MARK: - ViewModel
final class EventEditorViewModel: ObservableObject {
    @Published var draft: YoutubeCreateBroadcastRequest

    // Validation publisher example
    @Published private(set) var canSave: Bool = false
    private var cancellables = Set<AnyCancellable>()

    init(draft: YoutubeCreateBroadcastRequest = YoutubeCreateBroadcastRequest()) {
        self.draft = draft
        setupValidation()
    }

    private func setupValidation() {
        // Simple validation: requires non-empty title
        $draft
            .map { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .removeDuplicates()
            .assign(to: \.canSave, on: self)
            .store(in: &cancellables)
    }

    func save(completion: @escaping (Result<YoutubeCreateBroadcastRequest, Error>) -> Void) {
        // Replace with real saving logic (Firestore / API call / local persistence)
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.4) {
            // Return success for example
            DispatchQueue.main.async {
                completion(.success(self.draft))
            }
        }
    }
}

// MARK: - View
struct EventEditorView: View {
    @ObservedObject var vm: EventEditorViewModel
    @Environment(\.presentationMode) private var presentationMode
    var onSave: ((YoutubeCreateBroadcastRequest) -> Void)? = nil

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Title", text: $vm.draft.title)
                        .accessibilityLabel("Title")
                        .submitLabel(.next)

                    // Multiline description
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Description")
                            Spacer()
                            Text("\(vm.draft.description.count) chars")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        TextEditor(text: $vm.draft.description)
                            .frame(minHeight: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color(UIColor.separator), lineWidth: 0.5)
                            )
                            .accessibilityLabel("Description")
                    }
                }

                Section(header: Text("Schedule")) {
                    DatePicker("Start time", selection: $vm.draft.startTime, displayedComponents: [.date, .hourAndMinute])
                        .accessibilityLabel("Start time")
                }

                Section(header: Text("Privacy")) {
                    // Menu-style picker
                    Picker("Privacy status", selection: $vm.draft.privacy) {
                        ForEach(YoutubePrivacyStatus.allCases) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accessibilityLabel("Privacy status")
                }

                Section {
                    Toggle(isOn: $vm.draft.isForKids) {
                        Text("Made for kids")
                    }
                    .accessibilityHint("Turn on if this content is for children")
                }
            }
            .navigationTitle("Create Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        vm.save { result in
                            switch result {
                            case .success(let draft):
                                onSave?(draft)
                                presentationMode.wrappedValue.dismiss()
                            case .failure(let err):
                                // Optionally handle errors: show alert (not implemented here)
                                print("Save failed:", err)
                            }
                        }
                    }
                    .disabled(!vm.canSave)
                }
            }
        }
    }
}

// MARK: - Previews
struct EventEditorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EventEditorView(vm: EventEditorViewModel(), onSave: { draft in
                print("Saved draft:", draft)
            })
            .previewDisplayName("Light")

            EventEditorView(vm: EventEditorViewModel(draft: YoutubeCreateBroadcastRequest(title: "Birthday", description: "Bring cake", startTime: Date().addingTimeInterval(3600), privacy: .unlisted, isForKids: true)))
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark (sample)")
        }
    }
}
