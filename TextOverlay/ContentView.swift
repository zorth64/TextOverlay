//
//  ContentView.swift
//  TextOverlay
//
//  Created by zorth64 on 11/10/24.
//

import SwiftUI
import Cocoa

struct ContentView: View {
    var text: String = ""
    var icon: String? = nil
    var position: PositionModel = PositionModel(.center)
    var textAlign: HorizontalAlignment = .center
    var marginTop: CGFloat = 110
    var marginLeft: CGFloat = 50
    var marginBottom: CGFloat = 120
    var marginRight: CGFloat = 50
    var fadeInDuration: TimeInterval = 1
    var fadeOutDuration: TimeInterval = 1
    var duration: TimeInterval = 5
    var transition: TransitionEnum = .fade
    var autoDismiss: Bool = false
    var colorScheme: ColorSchemeEnum = .system
    var iconPosition: IconPosition = .left
    var iconColor: ColorModel = ColorModel(.primary)
    var iconRenderingMode: SymbolRenderingMode = .monochrome
    var maxWidth: CGFloat?
    var title: String?
    var titleAlign: HorizontalAlignment?
    
    init() {
        self.text = CommandLine.arguments[1].replacingOccurrences(of: "\\n", with: "\n")
        icon = UserDefaults.standard.string(forKey: "icon")
        if let positions = UserDefaults.standard.string(forKey: "position")?.components(separatedBy: ",") {
            if (positions.count == 1) {
                position = PositionModel(.withLabel(positions[0]))
            } else {
                position = PositionModel(.withLabel(positions[0]), .withLabel(positions[1]))
            }
        }
        
        let marginTop = UserDefaults.standard.integer(forKey: "marginTop")
        if (marginTop != 0) {
            self.marginTop = CGFloat(marginTop)
        }
        let marginLeft = UserDefaults.standard.integer(forKey: "marginLeft")
        if (marginLeft != 0) {
            self.marginLeft = CGFloat(marginLeft)
        }
        let marginBottom = UserDefaults.standard.integer(forKey: "marginBottom")
        if (marginBottom != 0) {
            self.marginBottom = CGFloat(marginBottom)
        }
        let marginRight = UserDefaults.standard.integer(forKey: "marginRight")
        if (marginRight != 0) {
            self.marginRight = CGFloat(marginRight)
        }
        
        let fadeInDuration = UserDefaults.standard.float(forKey: "fadeInDuration")
        if (fadeInDuration != 0.0) {
            self.fadeInDuration = TimeInterval(fadeInDuration)
        }
        let fadeOutDuration = UserDefaults.standard.float(forKey: "fadeOutDuration")
        if (fadeOutDuration != 0.0) {
            self.fadeOutDuration = TimeInterval(fadeOutDuration)
        }
        let duration = UserDefaults.standard.float(forKey: "duration")
        if (duration != 0) {
            self.duration = TimeInterval(duration)
        }
        
        transition = TransitionEnum.withLabel(UserDefaults.standard.string(forKey: "transition") ?? "")
        
        textAlign = HorizontalAlignment.withLabel(UserDefaults.standard.string(forKey: "textAlign") ?? "")
        
        autoDismiss = UserDefaults.standard.bool(forKey: "autoDismiss")
        
        colorScheme = ColorSchemeEnum.withLabel(UserDefaults.standard.string(forKey: "colorScheme") ?? "")
        
        iconPosition = IconPosition.withLabel(UserDefaults.standard.string(forKey: "iconPosition") ?? "")
        
        if let colors = UserDefaults.standard.string(forKey: "iconColor")?.components(separatedBy: ",") {
            switch colors.count {
            case 1: iconColor = ColorModel(colors[0].isValidHexColorCode() ? Color(hex: colors[0]) ?? .primary:                                      Color(colorName: colors[0]) ?? .primary)
            case 2: iconColor = ColorModel(colors[0].isValidHexColorCode() ? Color(hex: colors[0]) ?? .primary:                                      Color(colorName: colors[0]) ?? .primary,
                                           colors[1].isValidHexColorCode() ? Color(hex: colors[1]) ?? .primary: Color(colorName: colors[1]) ?? .primary)
            default: iconColor = ColorModel(colors[0].isValidHexColorCode() ? Color(hex: colors[0]) ?? .primary:                                     Color(colorName: colors[0]) ?? .primary,
                                            colors[1].isValidHexColorCode() ? Color(hex: colors[1]) ?? .primary: Color(colorName: colors[1]) ?? .primary,
                                            colors[2].isValidHexColorCode() ? Color(hex: colors[2]) ?? .primary: Color(colorName: colors[2]) ?? .primary)
            }
        }
        
        iconRenderingMode = SymbolRenderingMode.withLabel(UserDefaults.standard.string(forKey: "iconRenderingMode") ?? "")
        
        let maxWidth = UserDefaults.standard.integer(forKey: "maxWidth")
        if (maxWidth != 0) {
            self.maxWidth = CGFloat(maxWidth)
            if (UserDefaults.standard.string(forKey: "textAlign") == nil) {
                textAlign = .leading
            }
        }
        
        if let title = UserDefaults.standard.string(forKey: "title") {
            self.title = title
            
            if let textAlign = UserDefaults.standard.string(forKey: "titleAlign") {
                titleAlign = HorizontalAlignment.withLabel(textAlign)
            } else if (icon != nil) {
                titleAlign = textAlign
            } else {
                titleAlign = HorizontalAlignment.center
            }
        }
    }
    
    var body: some View {
        TextOverlayView(icon: icon,
                        text, position,
                        textAlign: textAlign,
                        marginTop: marginTop,
                        marginLeft: marginLeft,
                        marginBottom: marginBottom,
                        marginRight: marginRight,
                        fadeInDuration: fadeInDuration,
                        fadeOutDuration: fadeOutDuration,
                        duration: duration,
                        transition: transition,
                        autoDismiss: autoDismiss,
                        iconPosition: iconPosition,
                        iconColor: iconColor,
                        iconRenderingMode: iconRenderingMode,
                        maxWidth: maxWidth,
                        title: title,
                        titleAlign: titleAlign
        )
        .frame(width: NSScreen.main!.frame.width, height: NSScreen.main!.frame.height)
        .preferredColorScheme(colorScheme.getColorScheme)
    }
}

#Preview {
    ContentView()
}

