//
//  CGSize+Extensions.swift
//  WidgetDemo
//
//  Created by Changyeol Seo on 2023/06/29.
//

import Foundation
extension CGSize {
    func resize(keepingAspectRatio aspectRatio: CGFloat) -> CGSize {
        let widthRatio = self.width / aspectRatio
        let heightRatio = self.height * aspectRatio
        
        if widthRatio > heightRatio {
            return CGSize(width: heightRatio, height: self.height)
        } else {
            return CGSize(width: self.width, height: widthRatio)
        }
    }
    
    func resize(targetSize:CGSize, fill:Bool) -> CGSize {
        let hRatio = targetSize.height / self.height
        let wRatio = targetSize.width / self.width
        
        let a = resize(keepingAspectRatio: hRatio)
        let b = resize(keepingAspectRatio: wRatio)
        
        if(fill) {
            if(a.width > targetSize.width || a.height > targetSize.height) {
                return a
            }
            if(b.width > targetSize.width || b.height > targetSize.height) {
                return b
            }
        }
        else {
            if(a.width <= targetSize.width && a.height <= targetSize.width) {
                return a
            }
            if(b.width <= targetSize.width && b.height <= targetSize.height) {
                return b
            }
        }
        return targetSize
    }
}
