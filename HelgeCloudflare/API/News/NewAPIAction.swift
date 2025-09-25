//
//  NewAPIAction.swift
//  Default SwiftUI App
//
//  Created by Ryan Helgeson on 9/17/25.
//

import Foundation

enum NewsAPIAction: HTTPRequest {
    
    case fetchNews(FetchNewsRequest)
    
    var method: HTTPMethod {
        return switch self {
            case .fetchNews: .get
        }
    }
    
    var host: String {
        return switch self {
        case .fetchNews: "newsapi.org"
        }
    }
    
    var scheme: URLScheme {
        return switch self {
        case .fetchNews: .https
        }
    }
    
    var path: String {
        return switch self {
        case .fetchNews: "/v2/everything"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        return switch self {
        case .fetchNews(let request): request.queryItems()
        }
    }
    
    var body: Data? {
        return nil
    }
    
    var headers: [HTTPHeader] {
        return [HTTPHeader.apiKey]
    }
}

