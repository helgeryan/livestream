//
//  MainTabBarView.swift
//  Default SwiftUI App
//
//  Created by Ryan Helgeson on 8/7/25.
//

import SwiftUI

@Observable class MainTabBarViewModel {
    var selectedTab: MainTabBarItem = .home
}

struct MainTabBarView: View {
    @State var viewModel = MainTabBarViewModel()
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            ForEach(MainTabBarItem.allCases) { item in
                Tab(item.title,
                    systemImage: item.systemImage,
                    value: item) {
                    item.content()
                }
                
            }
        }
    }
}

#Preview {
    MainTabBarView()
}
