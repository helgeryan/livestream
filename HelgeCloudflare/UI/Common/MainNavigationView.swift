//
//  MainNavigationView.swift
//  Default SwiftUI App
//
//  Created by Ryan Helgeson on 8/7/25.
//

import SwiftUI

@Observable class MainNavigationViewModel {
    var navigationPath = NavigationPath()
}

struct MainNavigationView<Content: View>: View {
    // MARK: - Observable Properties
    @State var viewModel = MainNavigationViewModel()
    
    // MARK: - UI Content
    var title: String = ""
    var hidesBackButton: Bool = false
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            content()
                .navigationBarBackButtonHidden(hidesBackButton)
                .navigationTitle(title)
                .navigationDestination(for: String.self) { string in
                    Text(string)
                }
        }
    }
}

#Preview {
    MainNavigationView {
        NavigationLink("Navigate", value: "Text")
    }
}
