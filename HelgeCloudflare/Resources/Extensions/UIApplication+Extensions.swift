//
//  UIApplication+Extensions.swift
//  HelgeCloudflare
//
//  Created by Ryan Helgeson on 10/16/25.
//

import UIKit

extension UIApplication {
    var rootViewController: UIViewController? {
        connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first
    }
}
