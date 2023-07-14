//
//  CGFloat+Extensions.swift
//  readingGlasses
//
//  Created by 서창열 on 2023/07/14.
//

import Foundation
import SwiftUI
import UIKit

extension CGFloat {
    static var safeAreaInsetTop: CGFloat {
        return (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.top ?? 0
    }
    static var safeAreaInsetBottom: CGFloat {
        return (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.bottom ?? 0
    }
    static var safeAreaInsetLeft: CGFloat {
        return (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.left ?? 0
    }
    static var safeAreaInsetRight: CGFloat {
        return (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.right ?? 0
    }

}
