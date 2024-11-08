//
//  ColorSchemeEnum.swift
//  TextOverlay
//
//  Created by zorth64 on 12/10/24.
//

import SwiftUI

enum ColorSchemeEnum: CaseIterable {
    case light
    case dark
    case inverted
    case system
    
    static func withLabel(_ label: String) -> ColorSchemeEnum {
        if let result = self.allCases.first(where: { "\($0)" == label }) {
            return result
        } else {
            return .system
        }
    }
    
    var getColorScheme: ColorScheme {
        let systemApperance: NSAppearance = NSApplication.shared.effectiveAppearance
        
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .inverted: return systemApperance.name == NSAppearance.Name.darkAqua ? .light : .dark
        case .system: return systemApperance.name == NSAppearance.Name.darkAqua ? .dark : .light
        }
    }
}
