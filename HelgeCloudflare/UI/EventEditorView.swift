//
//  EventEditorView.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 10/20/25.
//

import SwiftUI

// MARK: - View
struct EventEditorView: View {
    @ObservedObject var vm: EventEditorViewModel
    @Environment(\.presentationMode) private var presentationMode
    var onSave: ((YoutubeCreateBroadcastRequest) -> Void)? = nil

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Title", text: $vm.draft.snippet.title)
                        .accessibilityLabel("Title")
                        .submitLabel(.next)

                    // Multiline description
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Description")
                            Spacer()
                            Text("\(vm.draft.snippet.description.count) chars")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        TextEditor(text: $vm.draft.snippet.description)
                            .frame(minHeight: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color(UIColor.separator), lineWidth: 0.5)
                            )
                            .accessibilityLabel("Description")
                    }
                }

                Section(header: Text("Schedule")) {
                    DatePicker("Start time", selection: $vm.draft.snippet.scheduledStartTime, displayedComponents: [.date, .hourAndMinute])
                        .accessibilityLabel("Start time")
                }

                Section(header: Text("Privacy")) {
                    // Menu-style picker
                    Picker("Privacy status", selection: $vm.draft.status.privacyStatus) {
                        ForEach(YoutubePrivacyStatus.allCases) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accessibilityLabel("Privacy status")
                }

                Section {
                    Toggle(isOn: $vm.draft.status.selfDeclaredMadeForKids) {
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
