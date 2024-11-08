//
//  BackdropLayerWrapper.swift
//  SystemInfo
//
//  Created by zorth64 on 14/10/24.
//

import SwiftUI

struct BackdropLayerWrapper: NSViewRepresentable {
    var effect: BackdropLayerView.Effect
    var blurRadius: CGFloat
    var saturationFactor: CGFloat
    var cornerRadius: CGFloat

    func makeNSView(context: Context) -> BackdropLayerView {
        let backdropView = BackdropLayerView()
        backdropView.effect = effect
        backdropView.blurRadius = blurRadius
        backdropView.saturationFactor = saturationFactor
        backdropView.cornerRadius = cornerRadius
        backdropView.layerUsesCoreImageFilters = false
        return backdropView
    }

    func updateNSView(_ nsView: BackdropLayerView, context: Context) {
        nsView.effect = effect
        nsView.blurRadius = blurRadius
        nsView.saturationFactor = saturationFactor
        nsView.cornerRadius = cornerRadius
        nsView.layerUsesCoreImageFilters = false
    }
}
