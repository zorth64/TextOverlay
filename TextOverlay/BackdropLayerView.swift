//
//  BackdropWrapper.swift
//  SystemInfo
//
//  Created by zorth64 on 14/10/24.
//

import SwiftUI
import QuartzCore

public class BackdropLayerView: NSVisualEffectView {
    private var backdrop: CABackdropLayer? = nil
    private var tint: CALayer? = nil
    private var container: CALayer? = nil
//    private var rim: CALayer? = nil
    
    public struct Effect {
            
        /// The `backgroundColor` is and autoclosure used to dynamically blend with
        /// the layers and contents behind the `BackdropView`.
        public let backgroundColor: () -> (NSColor)
        
        /// The `tintColor` is an autoclosure used to dynamically set the tint color.
        /// This is also the color used when the `BackdropView` is visually inactive.
        public let tintColor: () -> (NSColor)
        
        /// The `tintFilter` can be any object accepted by `CALayer.compositingFilter`.
        public let tintFilter: Any?
        
        /// Create a new `BackdropView.Effect` with the provided parameters.
        public init(_ backgroundColor: @autoclosure @escaping () -> (NSColor),
                    _ tintColor: @autoclosure @escaping () -> (NSColor),
                    _ tintFilter: Any?)
        {
            self.backgroundColor = backgroundColor
            self.tintColor = tintColor
            self.tintFilter = tintFilter
        }
        
        /// A clear effect (only applies blur and saturation); when inactive,
        /// appears transparent. Not suggested for typical use.
        public static var clear = Effect(NSColor(calibratedWhite: 1.00, alpha: 0.05),
                                         NSColor(calibratedWhite: 1.00, alpha: 0.00),
                                         nil)
        
        /// A medium light effect.
        public static var mediumLight = Effect(NSColor(calibratedWhite: 1.00, alpha: 0.30),
                                               NSColor(calibratedWhite: 0.94, alpha: 1.00),
                                               CAFilter.init(type: kCAFilterDarkenBlendMode))
        
        /// A light effect.
        public static var light = Effect(NSColor(calibratedWhite: 0.97, alpha: 0.70),
                                         NSColor(calibratedWhite: 0.94, alpha: 1.00),
                                         CAFilter.init(type: kCAFilterDarkenBlendMode))
        
        /// An ultra light effect.
        public static var ultraLight = Effect(NSColor(calibratedWhite: 0.97, alpha: 0.85),
                                              NSColor(calibratedWhite: 0.94, alpha: 1.00),
                                              CAFilter.init(type: kCAFilterDarkenBlendMode))
        
        /// A medium dark effect.
        public static var mediumDark = Effect(NSColor(calibratedWhite: 1.00, alpha: 0.40),
                                              NSColor(calibratedWhite: 0.84, alpha: 1.00),
                                              CAFilter.init(type: kCAFilterDarkenBlendMode))
        
        /// A dark effect.
        public static var dark = Effect(NSColor(calibratedWhite: 0.12, alpha: 0.45),
                                        NSColor(calibratedWhite: 0.16, alpha: 1.00),
                                        CAFilter.init(type: kCAFilterLightenBlendMode))
        
        /// An ultra dark effect.
        public static var ultraDark = Effect(NSColor(calibratedWhite: 0.08, alpha: 0.80),
                                             NSColor(calibratedWhite: 0.01, alpha: 1.00),
                                             CAFilter.init(type: kCAFilterLightenBlendMode))
        
        /// A selection effect that matches the user's current aqua color preference.
        public static var selection = Effect(NSColor.keyboardFocusIndicatorColor.withAlphaComponent(0.7),
                                             NSColor.keyboardFocusIndicatorColor,
                                             CAFilter.init(type: kCAFilterDestOver))
    }
    
    public final class BlendGroup {
        
        /// The notification posted upon deinit of a `BlendGroup`.
        fileprivate static let removedNotification = Notification.Name("BackdropView.BlendGroup.deinit")
        
        /// The internal value used for `CABackdropLayer.groupName`.
        fileprivate let value = UUID().uuidString
        
        /// Create a new `BlendGroup`.
        public init() {}
        
        deinit {
            
            // Alert all `BackdropView`s that we're about to be removed.
            // The `BackdropView` will figure out if it needs to update itself.
            NotificationCenter.default.post(name: BlendGroup.removedNotification,
                                            object: nil, userInfo: ["value": self.value])
        }
        
        /// The `global` BlendGroup, if it is desired that all backdrops share
        /// the same blending group through the layer tree (window).
        public static let global = BlendGroup()
        
        /// The default internal value used for `CABackdropLayer.groupName`.
        /// This is to be used if no `BlendGroup` is set on the `BackdropView`.
        fileprivate static func `default`() -> String {
            return UUID().uuidString
        }
    }
    
    public var effect: BackdropLayerView.Effect = .clear {
        didSet {
            self.backdrop?.backgroundColor = self.effect.backgroundColor().cgColor
            self.tint?.backgroundColor = self.effect.tintColor().cgColor
            self.tint?.compositingFilter = self.effect.tintFilter
        }
    }
    
    /// The gaussian blur radius of the visual effect. Animatable.
    public var blurRadius: CGFloat {
        get { return self.backdrop?.value(forKeyPath: "filters.gaussianBlur.inputRadius") as? CGFloat ?? 0 }
        set {
            self.backdrop?.setValue(newValue, forKeyPath: "filters.gaussianBlur.inputRadius")
        }
    }
    
    /// The background color saturation factor of the visual effect. Animatable.
    public var saturationFactor: CGFloat {
        get { return self.backdrop?.value(forKeyPath: "filters.colorSaturate.inputAmount") as? CGFloat ?? 0 }
        set {
            self.backdrop?.setValue(newValue, forKeyPath: "filters.colorSaturate.inputAmount")
        }
    }
    
    /// The corner radius of the view.
    public var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.container?.cornerRadius = self.cornerRadius
        }
    }
    
    public weak var blendingGroup: BlendGroup? = nil {
        didSet {
            self.backdrop?.groupName = self.blendingGroup?.value ?? BlendGroup.default()
        }
    }
    
    public override var blendingMode: NSVisualEffectView.BlendingMode {
        get { return self.window?.contentView == self ? .behindWindow : .withinWindow }
        set { }
    }
    
    /// Always `.appearanceBased`; use `effect` instead.
    public override var material: NSVisualEffectView.Material {
        get { return .appearanceBased }
        set { }
    }
    
    public override var state: NSVisualEffectView.State {
        get { return self._state }
        set { self._state = newValue }
    }
    
    private var _state: NSVisualEffectView.State = .active {
        didSet {
            // Don't be called when `commonInit` hasn't finished.
            guard let _ = self.backdrop else { return }
            
        }
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.commonInit()
    }
    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.commonInit()
    }

    private func commonInit() {
        self.wantsLayer = true
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
        self.layer?.masksToBounds = true
        self.layer?.name = "view"
        
        // Essentially, tell the `NSVisualEffectView` to not do its job:
        super.state = .active
        super.blendingMode = .behindWindow
        super.material = .appearanceBased
        self.setValue(true, forKey: "clear") // internal material
        
        // Set up our backdrop view:
        self.backdrop = CABackdropLayer()
        self.backdrop!.masksToBounds = true
        self.backdrop!.name = "backdrop"
//        self.backdrop!.allowsGroupBlending = true
        self.backdrop!.allowsGroupOpacity = true
        self.backdrop!.allowsEdgeAntialiasing = false
        self.backdrop!.disablesOccludedBackdropBlurs = true
        self.backdrop!.ignoresOffscreenGroups = false
        self.backdrop!.allowsInPlaceFiltering = false
        self.backdrop!.setValue(0.25, forKey: "scale")
        self.backdrop!.setValue(0.2, forKey: "bleedAmount")
        self.backdrop!.windowServerAware = true
        
        // Set up the backdrop filters:
        let blurFilter = CAFilter.init(type: kCAFilterGaussianBlur)!
        let saturateFilter = CAFilter.init(type: kCAFilterColorSaturate)!
        blurFilter.setValue(true, forKey: "inputNormalizeEdges")
        self.backdrop!.filters = [blurFilter, saturateFilter]

        
        self.tint = CALayer()
        self.tint?.name = "tint"
        self.container = CALayer()
        self.container?.name = "container"
        self.container?.masksToBounds = true
        self.container?.allowsEdgeAntialiasing = true
        self.container?.sublayers = [self.backdrop!, self.tint!]
        
        self.layer?.insertSublayer(self.container!, at: 0)
        
//        self.rim = CALayer()
//        self.rim!.name = "rim"
//        self.rim!.borderWidth = 0.5
//        self.rim!.opacity = 0.0
//        self.layer?.addSublayer(self.rim!)
        
        self._state = .active
        self.blendingMode = .behindWindow
        
        self.blurRadius = 10
        self.saturationFactor = 2.5
        self.effect = .dark
    }
    
    /// Update sublayer `frame`.
    public override func layout() {
        super.layout()
        self.container!.frame = self.layer?.bounds ?? .zero
        self.backdrop!.frame = self.layer?.bounds ?? .zero
        self.tint!.frame = self.layer?.bounds ?? .zero
//        self.rim!.frame = self.layer?.bounds.insetBy(dx: -0.5, dy: -0.5) ?? .zero
        //self.fallback?.frame = self.layer?.bounds ?? .zero
    }
    
    public override func viewDidChangeBackingProperties() {
        super.viewDidChangeBackingProperties()
        let scale = self.window?.backingScaleFactor ?? 1.0
        self.layer?.contentsScale = scale
        self.container!.contentsScale = scale
        self.backdrop!.contentsScale = scale
        self.tint!.contentsScale = scale
//        self.rim!.contentsScale = scale
        //self.fallback?.contentsScale = scale
    }
    
    
    
}
