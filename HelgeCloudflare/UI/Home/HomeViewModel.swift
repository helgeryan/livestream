//
//  HomeViewModel.swift
//  Default SwiftUI App
//
//  Created by Ryan Helgeson on 8/10/25.
//

import Foundation


@Observable class HomeViewModel {
    // MARK: - Properties
    var state: ViewModelState = .loaded
    /// View Articles to display
    var articles: [Article] = []
    /// Page size per request
    var pageSize: Int = 10
    /// Query
    var query = "NFL"
    /// Language to source from
    var sources: String = "en"
    
    
    // MARK: - Public Functions
    /// Load the items and manage state
    func loadNewsItems() {
        state = .loading
        Task {
            // Create request
            let request = FetchNewsRequest(source: sources,
                                           q: query,
                                           pageSize: pageSize)
            do {
                articles = try await NewsAPI.shared.fetchNews(request)
                state = .loaded
            } catch let error as CustomError {
                state = .error(error)
            } catch {
                state = .error(HomeViewError.failedToFetchArticles)
            }
        }
    }
}
