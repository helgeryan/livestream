//
//  ViewModelStateView.swift
//  Default SwiftUI App
//
//  Created by Ryan Helgeson on 8/11/25.
//

import SwiftUI

struct ViewModelStateView<Content: View>: View {
    // MARK: - Properties
    let state: ViewModelState
    let errorRetry: (() -> ())?
    
    // MARK: - UI Content
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack {
            switch state {
            case .loaded:
                content()
            case .loading:
                ProgressView()
            case .error(let error):
                ErrorView(error: error,
                          retry: errorRetry)
            }
        }
    }
}

struct ErrorView: View {
    // MARK: - Properties
    var error: any CustomError
    var retry: (() -> ())?

    // MARK: - UI Content
    var body: some View {
        VStack(spacing: 0) {
            Text(error.title ?? "Something went wrong")
                .font(.system(size: 16, weight: .bold))
                .padding(.bottom, 4)
            
            Text(error.userMessage)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(.gray)
                .padding(.bottom, 10)
            
            if let retry {
                Button("Retry") {
                    retry()
                }
                .font(.system(size: 13, weight: .regular))
            }
        }
    }
}
