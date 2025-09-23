//
//  NewsAPI.swift
//  Default SwiftUI App
//
//  Created by Ryan Helgeson on 8/10/25.
//

import Foundation

protocol NewsAPIClient {
    func fetchNews() async throws -> [NewsReponse]
}

final class NewsAPI {
    static let shared = NewsAPI()
    
    func fetchNews(_ request: FetchNewsRequest) async throws -> [Article] {
        let action = NewsAPIAction.fetchNews(request)
        let response: NewsReponse = try await APIManager.shared.sendRequest(action)
        return response.articles
    }
}
