//
//  AppDelegate.swift
//  ClipKeep
//
//  Created by Bhargav Murki on 8/10/24.

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        NotificationCenter.default.addObserver(self, selector: #selector(updateMenu), name: NSNotification.Name("ClipboardHistoryUpdated"), object: nil)
    }

    func setupMenuBar() {
        // Create the status item in the menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "📋" // You can set an icon here instead of text
        statusItem?.button?.target = self
        statusItem?.button?.action = #selector(showMenu)
    }

    @objc func showMenu() {
        updateMenu()
        statusItem?.button?.performClick(nil) // Open the menu immediately
    }

    @objc func updateMenu() {
        // Create the menu
        let menu = NSMenu()

        // Add clipboard history items
        for (index, item) in clipboardHistory.enumerated() {
            let menuItem = NSMenuItem(title: item, action: #selector(copyItem(_:)), keyEquivalent: "")
            menuItem.tag = index
            menu.addItem(menuItem)
        }

        // Add a separator
        menu.addItem(NSMenuItem.separator())

        // Add a quit option
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))

        // Update the menu
        statusItem?.menu = menu
    }

    @objc func copyItem(_ sender: NSMenuItem) {
        let item = clipboardHistory[sender.tag]
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(item, forType: .string)
    }

    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}
