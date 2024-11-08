//
//  IconColorModel.swift
//  TextOverlay
//
//  Created by zorth64 on 06/11/24.
//

import SwiftUI

struct ColorModel {
    var primary: Color = .primary
    var secondary: Color? = .primary
    var tertiary: Color? = .primary
    
    init(_ primary: Color, _ secondary: Color? = .primary, _ tertiary: Color? = .primary) {
        self.primary = primary
        self.secondary = secondary
        self.tertiary = tertiary
    }
}
