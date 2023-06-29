//
//  UIImage+Extensions.swift
//  WidgetDemo
//
//  Created by Changyeol Seo on 2023/06/28.
//

import Foundation
import UIKit

extension UIImage {
    func resized(to size: CGSize, fill:Bool = true) -> UIImage? {
        let newSize = size.resize(targetSize: size, fill: fill)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
