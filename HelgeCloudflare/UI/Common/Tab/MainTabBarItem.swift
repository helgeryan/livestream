//
//  MainTabBarItem.swift
//  Default SwiftUI App
//
//  Created by Ryan Helgeson on 8/7/25.
//

import SwiftUI

enum MainTabBarItem: Int, CaseIterable, Identifiable {
    
    case home = 0
    case menu
    case account
    
    var id: Int { self.rawValue }
    
    var systemImage: String {
        return switch self {
        case .home: "house"
        case .menu: "text.justify"
        case .account: "person"
        }
    }
    
    var title: String {
        return switch self {
        case .home: "Home"
        case .menu: "Menu"
        case .account: "Account"
        }
    }
    
    @ViewBuilder func content() -> some View {
        switch self {
        case .home:
            HomeView()
        case .menu:
            MenuView()
        case .account:
            AccountView()
        }
    }
}
