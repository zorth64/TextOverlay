//
//  SymbolRenderingMode+Extension.swift
//  TextOverlay
//
//  Created by zorth64 on 06/11/24.
//

import SwiftUI

extension SymbolRenderingMode {    
    static func withLabel(_ label: String) -> SymbolRenderingMode {
        let itemsMap: [String: SymbolRenderingMode] = [
            "monochrome": .monochrome,
            "hierarchical": .hierarchical,
            "palette": .palette,
            "multicolor": .multicolor
        ]
        return itemsMap[label] ?? .monochrome
    }

}
