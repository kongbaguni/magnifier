//
//  PinchZoomImageView.swift
//  readingGlasses
//
//  Created by 서창열 on 2023/09/12.
//

import SwiftUI

struct PinchZoomImageView: View {
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var previousScale: CGFloat = 1.0
    let image:Image

    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .scaleEffect(scale)
            .offset(offset)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        let delta = value / previousScale
                        previousScale = value
                        scale *= delta
                    }
                    .onEnded { _ in
                        previousScale = 1.0
                    }
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = value.translation
                    }
                    .onEnded { _ in
                        offset = .zero
                    }
            )
    }
}

struct PinchZoomImageView_Previews: PreviewProvider {
    static var previews: some View {
        PinchZoomImageView(image: Image("cat"))
    }
}
