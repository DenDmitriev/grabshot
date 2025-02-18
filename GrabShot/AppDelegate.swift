//
//  AppDelegate.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 17.08.2023.
//  

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var aboutBoxWindowController: NSWindowController?
    
    @AppStorage(DefaultsKeys.showOverview)
    var showOverview: Bool = true
    
    @AppStorage(DefaultsKeys.showOverview)
    var showNewFeatures: Bool = false
    
    @AppStorage(DefaultsKeys.version)
    private var version = 1.0
    
    let currentVersionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    
    func showAboutPanel() {
        if aboutBoxWindowController == nil {
            let styleMask: NSWindow.StyleMask = [.closable, .miniaturizable,/* .resizable,*/ .titled]
            let window = NSWindow()
            window.styleMask = styleMask
            window.title = NSLocalizedString("About application GrabShot", comment: "Title")
            window.contentView = NSHostingView(rootView: AboutView())
            window.center()
            aboutBoxWindowController = NSWindowController(window: window)
        }
        
        aboutBoxWindowController?.showWindow(aboutBoxWindowController?.window)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        updateKeys()
        firebaseSetup()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        FileService.clearJpegCache { _ in }
        FileService.clearVideoCache { _ in }
    }
    
    // MARK: Version configure
    private func updateKeys() {
        guard
            let currentVersionString,
            let currentVersion = Double(currentVersionString)
        else { return }
        if version <  currentVersion {
            version = currentVersion
            showNewFeatures = true
            showOverview = true
        }
    }
    
    // MARK: Firebase
    private func firebaseSetup() {
        setCrashOnExceptions()
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
    }
    
    private func setCrashOnExceptions() {
        UserDefaults.standard.register(
            defaults: ["NSApplicationCrashOnExceptions" : true]
        )
    }
}

struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffect = NSVisualEffectView()
        visualEffect.blendingMode = .behindWindow
        visualEffect.material = .fullScreenUI
        visualEffect.state = .active
        return visualEffect
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
    }
}
