//
//  UIApplication+Extensions.swift
//  GaweeBaweeBoh
//
//  Created by Changyeol Seo on 2023/07/11.
//

import Foundation
import UIKit

extension UIApplication {
   
    var rootViewController:UIViewController? {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return scene?.windows.last?.rootViewController
    }
    
    var lastViewController:UIViewController? {
        var vc = rootViewController
        if let ovc = vc {
            while ovc.presentedViewController != nil {
                vc = ovc.presentedViewController
            }
        }
        return vc
    }

}
