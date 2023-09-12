//
//  Image+Extensions.swift
//  readingGlasses
//
//  Created by 서창열 on 2023/09/12.
//

import SwiftUI

extension Image {
    @MainActor
    func getUIImage(newSize: CGSize) -> UIImage? {
        let image = resizable()
            .scaledToFill()
            .frame(width: newSize.width, height: newSize.height)            
            .clipped()
        if #available(iOS 16.0, *) {
            return ImageRenderer(content: image).uiImage
        } else {
            // Fallback on earlier versions
            return nil
        }
    }
}
