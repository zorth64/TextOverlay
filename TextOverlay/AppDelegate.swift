//
//  AppDelegate.swift
//  TextOverlay
//
//  Created by zorth64 on 11/10/24.
//

import Cocoa
import SwiftUI
import Foundation

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let windowController = MyWindowController()
        windowController.showWindow(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

