//
//  MyWindowController.swift
//  TextOverlay
//
//  Created by zorth64 on 11/10/24.
//

import Cocoa
import SwiftUI

class MyWindowController: NSWindowController {
    
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: NSScreen.main!.frame.width, height: NSScreen.main!.frame.height),
            styleMask: [
            ],
            backing: .buffered, defer: false)
        
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isOpaque = false
        window.hasShadow = false
        
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
        window.backgroundColor = NSColor.clear
        window.alphaValue = 1.0

        let contentView = ContentView()
            .edgesIgnoringSafeArea(.all)
            .allowsHitTesting(true)

        window.contentView = NSHostingView(rootView: contentView)

        self.init(window: window)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
}
