//
//  YoutubeError.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 10/21/25.
//

import Foundation
import SwiftUI

enum YoutubeError: CustomError {
    case noClientID
    case noAccessToken
    case generalError(YoutubeErrorResponse)
    
    
    var title: LocalizedStringKey? {
        return switch self {
        case .noClientID, .noAccessToken: "Youtube Authentication Failed"
        case .generalError: "Youtube Connection Failed"
        }
    }
    
    var userMessage: LocalizedStringKey {
        return switch self {
        case .noClientID: "No client ID, please contact support to resolve the issue."
        case .noAccessToken: "Access has expired, please sign in again."
        case .generalError(let response): LocalizedStringKey(response.error.message)
        }
    }
}
