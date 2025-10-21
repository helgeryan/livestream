//
//  HomeView.swift
//  Default SwiftUI App
//
//  Created by Ryan Helgeson on 8/7/25.
//

import SwiftUI


struct HomeView: View {
    // MARK: - Binding Properties
    @State var viewModel: HomeViewModel = .init()
    
    init() {
        loadItems()
    }
    
    // MARK: - UI Content
    var body: some View {
        MainNavigationView(title: "Home") {
            ViewModelStateView(state: viewModel.state,
                               errorRetry: loadItems) {
                if !viewModel.articles.isEmpty {
                    List {
                        Section("Top Stories") {
                            ForEach(viewModel.articles,  id: \.self) { item in
                                Text(item)
                            }
                        }
                    }
                    .refreshable {
                        loadItems()
                    }
                } else {
                    ErrorView(error: HomeViewError.articlesEmpty,
                              retry: loadItems)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func loadItems() {
        withAnimation {
            viewModel.loadNewsItems()
        }
    }
}


#Preview {
    HomeView()
}
