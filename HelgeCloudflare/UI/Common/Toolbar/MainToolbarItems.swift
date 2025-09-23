//
//  MainToolbarItems.swift
//  Default SwiftUI App
//
//  Created by Ryan Helgeson on 8/8/25.
//

import SwiftUI

enum MainToolbarItems: CaseIterable {
    case done
    case cancel
    case save
    
    var title: String? {
        return switch self {
        case .done: "Done"
        case .cancel: "Cancel"
        case .save: "Save"
        }
    }
    
    @ToolbarContentBuilder func toolbarItem(placement: ToolbarItemPlacement,
                                            action: @escaping () -> ()) -> some ToolbarContent {
        ToolbarItem(placement: placement) {
            if let title {
                Button(title, action: action)
            }
        }
    }
}
