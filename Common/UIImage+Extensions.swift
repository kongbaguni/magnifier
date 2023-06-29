//
//  UIImage+Extensions.swift
//  WidgetDemo
//
//  Created by Changyeol Seo on 2023/06/28.
//

import Foundation
import UIKit

extension UIImage {
    func resized(to size: CGSize, contentMode:UIView.ContentMode = .scaleAspectFill) -> UIImage? {
        let newSize = self.size.resized(targetSize: size, contentMode: contentMode)
        print(newSize)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
