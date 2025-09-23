//
//  HomeViewError.swift
//  Default SwiftUI App
//
//  Created by Ryan Helgeson on 8/11/25.
//

import SwiftUI

enum HomeViewError: CustomError {
    case failedToFetchArticles
    case articlesEmpty
    
    var title: LocalizedStringKey? {
        return switch self {
        case .failedToFetchArticles: "Failed to Fetch Articles"
        case .articlesEmpty: "No Articles Found"
        }
    }
    
    var userMessage: LocalizedStringKey {
        return switch self {
        case .failedToFetchArticles: "Check your internet connection and try again"
        case .articlesEmpty: "No articles were found. Please try again later."
        }
    }
    
}
