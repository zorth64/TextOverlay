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
    var backgroundWidth: CGFloat?
    var title: String?
    var titleAlign: HorizontalAlignment?
    
    private var isFullWidth: Bool {
        return backgroundWidth != nil
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
         backgroundWidth: CGFloat?,
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
        self.backgroundWidth = backgroundWidth
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
                                TextWithFullWidthBackgroundView(text: text, textAlign: textAlign, icon: icon, iconPosition: iconPosition, iconColor: iconColor, iconRenderingMode: iconRenderingMode, title: title, titleAlign: titleAlign, backgroundWidth: backgroundWidth)
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
                        .foregroundColor(.clear)
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
                        .foregroundColor(.clear)
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
                                    .foregroundColor(.primary)
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
                                    .foregroundColor(.clear)
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
    var backgroundWidth: CGFloat?
    
    private var textWithSymbolView: AnyView
    
    init(text: String, textAlign: HorizontalAlignment, icon: String?, iconPosition: IconPosition?, iconColor: ColorModel?, iconRenderingMode: SymbolRenderingMode?, title: String?, titleAlign: HorizontalAlignment?, backgroundWidth: CGFloat?) {
        self.text = text
        self.textAlign = textAlign
        self.icon = icon
        self.iconPosition = iconPosition
        self.iconColor = iconColor
        self.iconRenderingMode = iconRenderingMode
        self.title = title
        self.titleAlign = titleAlign
        self.backgroundWidth = backgroundWidth
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
            textWithSymbolView
                .multilineTextAlignment(textAlign.asTextAlignment)
        }
        .foregroundColor(.clear)
        .font(.system(size: 25))
        .lineSpacing(6)
        .modifier(FrameWidthModifier(width: backgroundWidth))
        .padding(.leading, icon != nil ? iconPosition == .left ? backgroundWidth != nil ? 0 : 65 : backgroundWidth != nil ? 0 : 20 : backgroundWidth != nil ? 2 : 0)
        .padding(.trailing, icon != nil ? iconPosition == .left ? backgroundWidth != nil ? 0 : 15 : backgroundWidth != nil ? 4 : 65 : backgroundWidth != nil ? 3 : 0)
        .padding(.top, 9)
        .padding(.bottom, 12)
        .background {
            BackdropLayerWrapper(effect: .clear, blurRadius: 5, saturationFactor: 1.3, cornerRadius: 0)
                .overlay(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.55))
        }
        .cornerRadius(10)
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
                        .padding(.leading, backgroundWidth != nil ? 0 : 10)
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
                    .padding(.leading, icon != nil ? iconPosition == .left ? backgroundWidth != nil ? 0 : 0 : backgroundWidth != nil ? 0 : 8 : backgroundWidth != nil ? 1 : 0)
                    .padding(.trailing, icon != nil ? iconPosition == .left ? backgroundWidth != nil ? 0 : 5 : backgroundWidth != nil ? 6 : 7 : backgroundWidth != nil ? 0 : 0)
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
                .modifier(FrameWidthModifier(width: backgroundWidth))
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

    private func parseText(_ text: String) -> some View {
        var result = Text("")
        let regex = try! NSRegularExpression(pattern: "\\[(.*?)\\]", options: [])

        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        var lastRangeEnd = text.startIndex

        for match in matches {
            let range = match.range(at: 1)
            let symbolRange = Range(range, in: text)!
            let matchRange = Range(match.range(at: 0), in: text)!

            let textBeforeSymbol = String(text[lastRangeEnd..<matchRange.lowerBound])
            
            result = result + Text(textBeforeSymbol)

            let symbolName = String(text[symbolRange])
            let symbolText = Text(Image(systemName: symbolName))

            result = result + symbolText

            lastRangeEnd = matchRange.upperBound
        }

        if lastRangeEnd < text.index(text.endIndex, offsetBy: -1) {
            result = result + Text(String(text[lastRangeEnd..<text.endIndex]))
        }

        return result
    }
}

private struct FrameWidthModifier: ViewModifier {
    var width: CGFloat?
    
    @ViewBuilder func body(content: Content) -> some View {
        if let width = width {
            content.frame(maxWidth: width)
        } else {
            content
        }
    }
}
