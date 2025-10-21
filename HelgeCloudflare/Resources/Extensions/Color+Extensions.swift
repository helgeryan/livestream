//
//  Color+Extensions.swift
//  Default SwiftUI App
//
//  Created by Ryan Helgeson on 9/17/25.
//
import SwiftUI

extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r, g, b, a: CGFloat
        switch length {
        case 6: // RGB (24-bit)
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255
            b = CGFloat(rgb & 0x0000FF) / 255
            a = 1.0
        case 8: // ARGB (32-bit)
            a = CGFloat((rgb & 0xFF000000) >> 24) / 255
            r = CGFloat((rgb & 0x00FF0000) >> 16) / 255
            g = CGFloat((rgb & 0x0000FF00) >> 8) / 255
            b = CGFloat(rgb & 0x000000FF) / 255
        default:
            return nil
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

extension Color {
    init?(hex: String) {
        guard let uiColor = UIColor(hex: hex) else { return nil }
        self.init(uiColor)
    }
}
