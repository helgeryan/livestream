//
//  ViewModelState.swift
//  Default SwiftUI App
//
//  Created by Ryan Helgeson on 8/11/25.
//

import Foundation

enum ViewModelState {
    case loading
    case loaded
    case error(CustomError)
}
