//
//  View+Extensions.swift
//  readingGlasses
//
//  Created by Changyeol Seo on 2023/09/21.
//

import Foundation
import SwiftUI
extension View {
    func widgetBackground(backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}

