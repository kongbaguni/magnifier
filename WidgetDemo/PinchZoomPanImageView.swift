//
//  PinchZoomImageView.swift
//  readingGlasses
//
//  Created by 서창열 on 2023/09/12.
//

import SwiftUI

struct PinchZoomPanImageView: View {
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var previousScale: CGFloat = 1.0
    @State private var initialOffset: CGSize = .zero
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
                        if value.startLocation.x < UIScreen.main.bounds.width / 2 {
                            offset = CGSize(
                                width: initialOffset.width + value.translation.width,
                                height: initialOffset.height + value.translation.height
                            )
                        }
                    }
                    .onEnded { value in
                        if value.startLocation.x < UIScreen.main.bounds.width / 2 {
                            initialOffset = offset
                        }
                    }
            )
    }
}

struct PinchZoomPenImageView_Previews: PreviewProvider {
    static var previews: some View {
        PinchZoomPanImageView(image: Image("cat"))
    }
}
