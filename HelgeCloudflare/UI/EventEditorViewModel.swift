//
//  EventEditorViewModel.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 10/20/25.
//

import Foundation
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
            .map { !$0.snippet.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
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
