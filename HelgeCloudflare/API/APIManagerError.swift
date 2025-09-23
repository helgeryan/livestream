//
//  APIManagerError.swift
//  Default SwiftUI App
//
//  Created by Ryan Helgeson on 9/17/25.
//

import SwiftUI

enum APIManagerError: CustomError {
    
    case failedToCreateRequest
    case noInternetConnection
    case noServerConenction
    case invalidResponse
    case decodingFailed
    
    var title: LocalizedStringKey? {
        return switch self {
        case .failedToCreateRequest: "Bad Request"
        case .noInternetConnection: "No Internet Connection"
        case .noServerConenction: "No Server Connection"
        case .invalidResponse: "Invalid Response"
        case .decodingFailed: "Failed to Decode Response"
        }
    }
    
    var userMessage: LocalizedStringKey {
        return switch self {
        case .failedToCreateRequest: "Failed to create data request"
        case .noInternetConnection: "Please check internet connection and try again"
        case .noServerConenction: "Server connection failed, please try again later"
        case .invalidResponse: "The response was invalid, please try again later, or refresh the app"
        case .decodingFailed: "Bad data returned from server"
        }
    }
    
    var errorDescription: String? {
        return switch self {
        default: nil // TODO: - Implement this
        }
    }
}
