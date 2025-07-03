//
//  TextOverlayView.swift
//  TextOverlay
//
//  Created by zorth64 on 12/10/24.
//

import SwiftUI
import Combine

struct TextOverlayView: View {
    var icon: String?
    var text: String
    var position: PositionModel
    var textAlign: HorizontalAlignment
    var marginTop: CGFloat
    var marginLeft: CGFloat
    var marginBottom: CGFloat
    var marginRight: CGFloat
    var fadeInDuration: TimeInterval
    var fadeOutDuration: TimeInterval
    var duration: TimeInterval
    var transition: TransitionEnum = .fade
    var autoDismiss: Bool = false
    var iconPosition: IconPosition
    var iconColor: ColorModel
    var iconRenderingMode: SymbolRenderingMode = .monochrome
    var maxWidth: CGFloat?
    var title: String?
    var titleAlign: HorizontalAlignment?
    
    private var isFullWidth: Bool {
        return maxWidth != nil
    }
    
    @State var showOverlay: Bool = false
    @State var showOverlayFullscreen: Bool = false
    
    @State private var timerCancellable: AnyCancellable? = nil
    @State private var timerExpired = false
    
    @State private var isMouseOver = false
    
    init(icon: String? = nil,
         _ text: String,
         _ position: PositionModel,
         textAlign: HorizontalAlignment,
         marginTop: CGFloat,
         marginLeft: CGFloat,
         marginBottom: CGFloat,
         marginRight: CGFloat,
         fadeInDuration: TimeInterval,
         fadeOutDuration: TimeInterval,
         duration: TimeInterval,
         transition: TransitionEnum,
         autoDismiss: Bool,
         iconPosition: IconPosition,
         iconColor: ColorModel,
         iconRenderingMode: SymbolRenderingMode,
         maxWidth: CGFloat?,
         title: String?,
         titleAlign: HorizontalAlignment?
    ) {
        self.icon = icon
        self.text = text
        self.position = position
        self.textAlign = textAlign
        self.marginTop = marginTop
        self.marginLeft = marginLeft
        self.marginBottom = marginBottom
        self.marginRight = marginRight
        self.fadeInDuration = fadeInDuration
        self.fadeOutDuration = fadeOutDuration
        self.duration = duration
        self.transition = transition
        self.autoDismiss = autoDismiss
        self.iconPosition = iconPosition
        self.iconColor = iconColor
        self.iconRenderingMode = iconRenderingMode
        self.maxWidth = maxWidth
        self.title = title
        self.titleAlign = titleAlign
    }
    
    fileprivate func hideViewWithTransition() {
        if (transition == .scale) {
            withAnimation(.easeIn(duration: fadeOutDuration)) {
                showOverlay = false
            }
        } else {
            withAnimation(.easeIn(duration: fadeOutDuration)) {
                showOverlayFullscreen = false
            }
        }
    }
    
    var body: some View {
        ZStack {
            if (showOverlayFullscreen) {
                VStack {
                    if (position.vertical == .bottom) {
                        Spacer()
                    }
                    HStack {
                        if (position.horizontal == .right) {
                            Spacer()
                        }
                        if (showOverlay) {
                            if (icon == nil && !isFullWidth) {
                                TextWithBackgroundView(text: text, textAlign: textAlign, title: title, isMouseOver: $isMouseOver)
                                    .transition(transition == .scale ?
                                                transition.getTransition.combined(with: AnyTransition.opacity) :
                                                    AnyTransition.identity)
                                    .onTapGesture {
                                        if (transition == .scale) {
                                            withAnimation(.easeIn(duration: fadeOutDuration)) {
                                                showOverlay = false
                                            }
                                        } else {
                                            withAnimation(.easeIn(duration: fadeOutDuration)) {
                                                showOverlayFullscreen = false
                                            }
                                        }
                                    }
                                    .onChange(of: isMouseOver) {
                                        if (!isMouseOver && timerExpired) {
                                            startTimer(2.0)
                                        }
                                    }
                                    .onDisappear {
                                        timerCancellable?.cancel()
                                        NSApp.terminate(nil)
                                    }
                            } else {
                                TextWithFullWidthBackgroundView(text: text, textAlign: textAlign, icon: icon, iconPosition: iconPosition, iconColor: iconColor, iconRenderingMode: iconRenderingMode, title: title, titleAlign: titleAlign, maxWidth: maxWidth)
                                    .transition(transition == .scale ?
                                                transition.getTransition.combined(with: AnyTransition.opacity) :
                                                    AnyTransition.identity)
                                    .onTapGesture {
                                        if (transition == .scale) {
                                            withAnimation(.easeIn(duration: fadeOutDuration)) {
                                                showOverlay = false
                                            }
                                        } else {
                                            withAnimation(.easeIn(duration: fadeOutDuration)) {
                                                showOverlayFullscreen = false
                                            }
                                        }
                                    }
                                    .onHover{ over in
                                        isMouseOver = over
                                        if (!isMouseOver && timerExpired) {
                                            startTimer(2.0)
                                        }
                                    }
                                    .onDisappear {
                                        timerCancellable?.cancel()
                                        NSApp.terminate(nil)
                                    }
                            }
                        }
                        if (position.horizontal == .left) {
                            Spacer()
                        }
                    }
                    if (position.vertical == .top) {
                        Spacer()
                    }
                    
                }
                .padding(.top, marginTop)
                .padding(.leading, marginLeft)
                .padding(.bottom, marginBottom)
                .padding(.trailing, marginRight)
                .transition(transition != .scale ?
                            transition.getTransition.combined(with: AnyTransition.opacity) :
                                AnyTransition.identity)
                .onDisappear {
                    timerCancellable?.cancel()
                    NSApp.terminate(nil)
                }
            }
        }
        .onAppear {
            if (transition == .scale) {
                showOverlayFullscreen = true
                withAnimation(.bouncy(duration: fadeInDuration)) {
                    showOverlay = true
                }
            } else {
                showOverlay = true
                withAnimation(.smooth(duration: fadeInDuration)) {
                    showOverlayFullscreen = true
                }
            }
            if (autoDismiss) {
                DispatchQueue.main.asyncAfter(deadline: .now() + fadeInDuration) {
                    startTimer(duration)
                }
            }
        }
    }
    
    func startTimer(_ duration: TimeInterval) {
        timerExpired = false
        
        timerCancellable?.cancel()

        let timer = Timer.publish(every: duration, on: .main, in: .common).autoconnect()

        timerCancellable = timer.sink { _ in
            if (!isMouseOver) {
                hideViewWithTransition()
            }
            timerExpired = true
        }
    }
}

private struct TextWithBackgroundView: View {
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    @Environment(\.colorScheme) var colorScheme
    
    var text: String
    var textAlign: HorizontalAlignment = .center
    var title: String?
    
    @Binding var isMouseOver: Bool
    
    var body: some View {
        ZStack {
            VStack(alignment: textAlign, spacing: -32) {
                if let title = title {
                    TextWithInlineSymbol(text: title)
                        .hidden()
                        .font(.system(size: 25, weight: .bold))
                        .padding(.top, 8)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                        .padding(.bottom, 11)
                        .cornerRadius(10)
                        .padding(.bottom, 20)
                }
                ForEach(text.split(separator: "\n"), id: \.self) { line in
                    TextWithInlineSymbol(text: String(line))
                        .hidden()
                        .font(.system(size: 25))
                        .padding(.top, 8)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                        .padding(.bottom, 11)
                        .cornerRadius(10)
                        .padding(.bottom, 20)
                }
            }
            .background {
                BackdropLayerWrapper(effect: .clear, blurRadius: 5, saturationFactor: 1.3, cornerRadius: 0)
                    .overlay(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.55))
                    .mask {
                        VStack(alignment: textAlign, spacing: -32) {
                            if let title = title {
                                TextWithInlineSymbol(text: title)
                                    .hidden()
                                    .font(.system(size: 25, weight: .bold))
                                    .padding(.top, 8)
                                    .padding(.leading, 10)
                                    .padding(.trailing, 10)
                                    .padding(.bottom, 11)
                                    .background(.black)
                                    .cornerRadius(10)
                                    .padding(.bottom, 20)
                            }
                            ForEach(text.split(separator: "\n"), id: \.self) { line in
                                TextWithInlineSymbol(text: String(line))
                                    .hidden()
                                    .font(.system(size: 25))
                                    .padding(.top, 8)
                                    .padding(.leading, 10)
                                    .padding(.trailing, 10)
                                    .padding(.bottom, 11)
                                    .background(.black)
                                    .cornerRadius(10)
                                    .padding(.bottom, 20)
                            }
                        }
                    }
                    .compositingGroup()
            }
            .compositingGroup()
            .shadow(color: colorScheme == .dark ? .black : .clear, radius: 0.36)
            .shadow(color: colorScheme == .dark ? .black : .clear, radius: 0.36)
            .shadow(color: colorScheme == .dark ? .black : .clear, radius: 0.36)
            .shadow(color: colorScheme == .dark ? .gray : .clear, radius: 0.35)
            .shadow(color: colorScheme == .dark ? .gray : .clear, radius: 0.35)
            .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.4), radius: 1)
            .shadow(color: .black.opacity(0.3), radius: 15, y: 7)
            VStack(alignment: textAlign, spacing: -32) {
                if let title = title {
                    TextWithInlineSymbol(text: title)
                        .foregroundColor(.primary)
                        .font(.system(size: 25, weight: .bold))
                        .padding(.top, 8)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                        .padding(.bottom, 11)
                        .padding(.bottom, 20)
                        .shadow(color: colorScheme == .dark ? .black.opacity(0.7) : .white, radius: 5, y: 0)
                        .shadow(color: colorScheme == .dark ? .clear : .white.opacity(0.25), radius: 5, y: 0)
                }
                ForEach(text.split(separator: "\n"), id: \.self) { line in
                    TextWithInlineSymbol(text: String(line))
                        .foregroundColor(.primary)
                        .font(.system(size: 25))
                        .padding(.top, 8)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                        .padding(.bottom, 11)
                        .padding(.bottom, 20)
                        .shadow(color: colorScheme == .dark ? .black.opacity(0.7) : .white, radius: 5, y: 0)
                        .shadow(color: colorScheme == .dark ? .clear : .white.opacity(0.25), radius: 5, y: 0)
                }
                .onHover{ over in
                    isMouseOver = over
                }
            }
        }
    }
}

private struct TextWithFullWidthBackgroundView: View {
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    @Environment(\.colorScheme) var colorScheme
    
    var text: String
    var textAlign: HorizontalAlignment = .leading
    var icon: String?
    var iconPosition: IconPosition? = .left
    var iconColor: ColorModel? = ColorModel(.primary)
    var iconRenderingMode: SymbolRenderingMode?
    var title: String?
    var titleAlign: HorizontalAlignment?
    var maxWidth: CGFloat?
    
    private var textWithSymbolView: AnyView
    
    init(text: String, textAlign: HorizontalAlignment, icon: String?, iconPosition: IconPosition?, iconColor: ColorModel?, iconRenderingMode: SymbolRenderingMode?, title: String?, titleAlign: HorizontalAlignment?, maxWidth: CGFloat?) {
        self.text = text
        self.textAlign = textAlign
        self.icon = icon
        self.iconPosition = iconPosition
        self.iconColor = iconColor
        self.iconRenderingMode = iconRenderingMode
        self.title = title
        self.titleAlign = titleAlign
        self.maxWidth = maxWidth
        textWithSymbolView = AnyView(TextWithInlineSymbol(text: self.text))
    }
    
    var body: some View {
        VStack(alignment: title != nil ? titleAlign! : .center, spacing: 5) {
            if (title != nil) {
                Text(title!)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.bottom, 2)
            }
            TextWithInlineSymbol(text: self.text)
                .multilineTextAlignment(textAlign.asTextAlignment)
        }
        .hidden()
        .offset(x: 5)
        .font(.system(size: 25))
        .lineSpacing(6)
        .modifier(FrameMaxWidthModifier(maxWidth: maxWidth))
        .padding(.leading, icon != nil ? iconPosition == .left ? maxWidth != nil ? 0 : 65 : maxWidth != nil ? 0 : 20 : maxWidth != nil ? 2 : 0)
        .padding(.trailing, icon != nil ? iconPosition == .left ? maxWidth != nil ? 0 : 15 : maxWidth != nil ? 4 : 65 : maxWidth != nil ? 3 : 0)
        .padding(.top, 9)
        .padding(.bottom, 12)
        .background {
            BackdropLayerWrapper(effect: .clear, blurRadius: 5, saturationFactor: 1.3, cornerRadius: 0)
                .overlay(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.55))
        }
        .cornerRadius(10)
        .shadow(color: colorScheme == .dark ? .black : .clear, radius: 0.36)
        .shadow(color: colorScheme == .dark ? .black : .clear, radius: 0.36)
        .shadow(color: colorScheme == .dark ? .black : .clear, radius: 0.36)
        .shadow(color: colorScheme == .dark ? .gray : .clear, radius: 0.35)
        .shadow(color: colorScheme == .dark ? .gray : .clear, radius: 0.35)
        .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.4), radius: 1)
        .shadow(color: .black.opacity(0.3), radius: 15, y: 7)
        .overlay(
            HStack(alignment: .center) {
                if (icon != nil && iconPosition == .left) {
                    Image(systemName: icon!)
                        .symbolRenderingMode(iconRenderingMode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(iconColor!.primary, iconColor!.secondary!, iconColor!.tertiary!)
                        .frame(width: 50, height: 50)
                        .padding(.leading, maxWidth != nil ? 0 : 10)
                }
                VStack(alignment: title != nil ? titleAlign! : .center, spacing: 5) {
                    if (title != nil) {
                        Text(title!)
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .padding(.bottom, 2)
                    }
                    textWithSymbolView
                        .multilineTextAlignment(textAlign.asTextAlignment)
                }
                    .foregroundColor(.primary)
                    .font(.system(size: 25))
                    .lineSpacing(6)
                    .padding(.leading, icon != nil ? iconPosition == .left ? maxWidth != nil ? 0 : 0 : maxWidth != nil ? 0 : 8 : maxWidth != nil ? 1 : 0)
                    .padding(.trailing, icon != nil ? iconPosition == .left ? maxWidth != nil ? 0 : 5 : maxWidth != nil ? 6 : 7 : maxWidth != nil ? 0 : 0)
                    .offset(x: 2, y: -2)
                if (icon != nil && iconPosition == .right) {
                    Image(systemName: icon!)
                        .symbolRenderingMode(iconRenderingMode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(iconColor!.primary, iconColor!.secondary!, iconColor!.tertiary!)
                        .padding(.trailing, 0)
                        .frame(width: 50, height: 50)
                }
            }
                .modifier(FrameMaxWidthModifier(maxWidth: maxWidth))
                .shadow(color: colorScheme == .dark ? .black.opacity(0.7) : .white, radius: 5, y: 0)
                .shadow(color: colorScheme == .dark ? .clear : .white.opacity(0.25), radius: 5, y: 0)
                ,   alignment: .leading
        )
        .compositingGroup()
    }
}

private struct TextWithInlineSymbol: View {
    let text: String

    var body: some View {
        parseText(text)
    }

    private func parseText(_ text: String) -> Text {
        var result = Text("")

        let colorRegex = try! NSRegularExpression(pattern: #"<color=([a-zA-Z#0-9]+);(.*?)>"#, options: [.dotMatchesLineSeparators])
        let fullRange = NSRange(location: 0, length: text.utf16.count)

        var lastRangeEnd = text.startIndex

        let matches = colorRegex.matches(in: text, options: [], range: fullRange)

        for match in matches {
            guard let colorRange = Range(match.range(at: 1), in: text),
                  let contentRange = Range(match.range(at: 2), in: text) else { continue }

            let matchStartUTF16 = text.utf16.index(text.utf16.startIndex, offsetBy: match.range.location)
            let matchStartIndex = String.Index(matchStartUTF16, within: text)!
            let beforeText = String(text[lastRangeEnd..<matchStartIndex])

            result = result + parseSymbols(beforeText)

            let colorSpec = String(text[colorRange])
            let innerContent = String(text[contentRange])

            let color = Color(colorName: colorSpec) ?? Color(hex: colorSpec)

            if let color {
                let coloredText = parseSymbols(innerContent).foregroundColor(color)
                result = result + coloredText
            } else {
                result = result + parseSymbols("<color=\(colorSpec);\(innerContent)>")
            }

            if let matchRange = Range(match.range, in: text) {
                lastRangeEnd = matchRange.upperBound
            }
        }

        if lastRangeEnd < text.endIndex {
            let remaining = String(text[lastRangeEnd..<text.endIndex])
            result = result + parseSymbols(remaining)
        }

        return result
    }

    private func parseSymbols(_ text: String) -> Text {
        var result = Text("")
        let regex = try! NSRegularExpression(pattern: "\\[(.*?)\\]", options: [])

        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        var lastRangeEnd = text.startIndex

        for match in matches {
            guard let symbolRange = Range(match.range(at: 1), in: text),
                  let matchRange = Range(match.range(at: 0), in: text) else { continue }

            let textBeforeSymbol = String(text[lastRangeEnd..<matchRange.lowerBound])
            result = result + Text(textBeforeSymbol)

            let symbolName = String(text[symbolRange])
            result = result + Text(Image(systemName: symbolName))

            lastRangeEnd = matchRange.upperBound
        }

        if lastRangeEnd < text.endIndex {
            result = result + Text(String(text[lastRangeEnd..<text.endIndex]))
        }

        return result
    }
}

private struct FrameMaxWidthModifier: ViewModifier {
    var maxWidth: CGFloat?
    
    @ViewBuilder func body(content: Content) -> some View {
        if let maxWidth = maxWidth {
            content.frame(maxWidth: maxWidth)
        } else {
            content
        }
    }
}
