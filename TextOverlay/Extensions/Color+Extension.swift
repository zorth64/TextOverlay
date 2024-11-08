//
//  Color+Extension.swift
//  TextOverlay
//
//  Created by zorth64 on 06/11/24.
//

import SwiftUI

extension Color {
    init?(colorName: String) {
        switch colorName.lowercased() {
        case "black": self = .black
        case "blue": self = .blue
        case "brown": self = .brown
        case "clear": self = .clear
        case "cyan": self = .cyan
        case "gray": self = .gray
        case "green": self = .green
        case "indigo": self = .indigo
        case "mint": self = .mint
        case "orange": self = .orange
        case "pink": self = .pink
        case "purple": self = .purple
        case "red": self = .red
        case "teal": self = .teal
        case "white": self = .white
        case "yellow": self = .yellow
        case "primary": self = .primary
        case "secondary": self = .secondary
        case "accent": self = .accentColor
        case "accentColor": self = .accentColor
        default: return nil
        }
    }
    
    init?(hex: String) {
        var hexCode = hex.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if hexCode.hasPrefix("#") {
            hexCode.removeFirst()
        }
        
        let hexLength = hexCode.count
        guard hexLength == 6 || hexLength == 3 else { return nil }
        
        if hexLength == 3 {
            hexCode = hexCode.map { String(repeating: $0, count: 2) }.joined()
        }
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexCode).scanHexInt64(&rgb) else { return nil }
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}
