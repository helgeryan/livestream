//
//  CustomError.swift
//  Default SwiftUI App
//
//  Created by Ryan Helgeson on 9/17/25.
//

import SwiftUI

protocol CustomError: LocalizedError {
    var errorDescription: String? { get }
    var title: LocalizedStringKey? { get }
    var userMessage: LocalizedStringKey { get }
}
