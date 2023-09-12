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
            .frame(width: newSize.width, height: newSize.height)
            .scaledToFit()
        if #available(iOS 16.0, *) {
            return ImageRenderer(content: image).uiImage
        } else {
            // Fallback on earlier versions
            return nil
        }
    }
}
