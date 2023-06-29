//
//  CGSize+Extensions.swift
//  WidgetDemo
//
//  Created by Changyeol Seo on 2023/06/29.
//

import Foundation
import UIKit

extension CGSize {
    func resized(targetSize: CGSize, contentMode:UIView.ContentMode) -> CGSize {
        switch contentMode {
        case .scaleAspectFit:
            let widthRatio = targetSize.width / self.width
            let heightRatio = targetSize.height / self.height
            
            let scale = min(widthRatio, heightRatio)
            let resizedWidth = self.width * scale
            let resizedHeight = self.height * scale
            
            return CGSize(width: resizedWidth, height: resizedHeight)
            
        case .scaleAspectFill:
            let widthRatio = targetSize.width / self.width
            let heightRatio = targetSize.height / self.height
            
            let scale = max(widthRatio, heightRatio)
            let resizedWidth = self.width * scale
            let resizedHeight = self.height * scale
            
            return CGSize(width: resizedWidth, height: resizedHeight)
        default:
            return targetSize
        }
    }
}
