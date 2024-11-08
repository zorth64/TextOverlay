//
//  HorizontalAlignment+Extension.swift
//  TextOverlay
//
//  Created by zorth64 on 12/10/24.
//

import SwiftUI

extension HorizontalAlignment {
    public var asTextAlignment: TextAlignment {
        switch self {
            case .leading: return TextAlignment.leading
            case .center: return TextAlignment.center
            case .trailing: return TextAlignment.trailing
            default: return TextAlignment.center
        }
    }
    
    public var asAlignment: Alignment {
        switch self {
            case .leading: return Alignment.leading
            case .center: return Alignment.center
            case .trailing: return Alignment.trailing
            default: return Alignment.center
        }
    }
    
    static func withLabel(_ label: String) -> HorizontalAlignment {
        let alignmentMap: [String: HorizontalAlignment] = [
            "leading": .leading,
            "left": .leading,
            "center": .center,
            "trailing": .trailing,
            "right": .trailing
        ]
        return alignmentMap[label] ?? .center
    }
}
