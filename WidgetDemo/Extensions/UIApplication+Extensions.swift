//
//  UIApplication+Extensions.swift
//  GaweeBaweeBoh
//
//  Created by Changyeol Seo on 2023/07/11.
//

import Foundation
import UIKit

extension UIApplication {
    class var keyWindowScene:UIWindowScene? {
        return UIApplication.shared.connectedScenes.first as? UIWindowScene
    }
    
    class var keyWindow:UIWindow? {
        keyWindowScene?.windows.first(where: {$0.isKeyWindow})
    }    
    
    class var topViewController:UIViewController? {
        var vc = UIApplication.keyWindow?.rootViewController
        while vc?.presentingViewController != nil {
            vc = vc?.presentingViewController
        }
        return vc
    }
}
