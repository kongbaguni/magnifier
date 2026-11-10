//
//  WidgetDemoApp.swift
//  WidgetDemo
//
//  Created by Changyeol Seo on 2023/06/28.
//

import SwiftUI
import WidgetKit

@main
struct WidgetDemoApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            if newValue == .background {
                // Request widget timeline reload when app goes to background
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
}
