//
//  FetchNewRequest.swift
//  Default SwiftUI App
//
//  Created by Ryan Helgeson on 9/17/25.
//

import Foundation

struct FetchNewsRequest: Codable {
    var source: String?
    var q: String? = nil
    var sortBy: String? = nil
    var from: String? = nil
    var to: String? = nil
    var language: String? = nil
    var pageSize: Int? = nil
    var page: Int? = nil
    var domains: [String]? = nil
    var excludeDomains: [String]? = nil
}

struct NewsReponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

struct Article: Codable, Hashable {
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: URL
    let urlToImage: URL?
    let publishedAt: String
    let content: String?
}

struct Source: Codable, Hashable {
    let id: String?
    let name: String
}
