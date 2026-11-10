//
//  ImageScrollView.swift
//  readingGlasses
//
//  Created by 서창열 on 11/10/26.
//
import SwiftUI
struct ImageScrollView: View {
    @ObservedObject var viewModel: CameraViewModel

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                // UIImage는 id: \.self보다 indices나 고유 ID를 사용하는 것이 안전합니다.
                ForEach(viewModel.images.indices, id: \.self) { index in
                    let image = viewModel.images[index]
                    Button {
                        viewModel.showImage(image)
                    } label: {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                            .padding(5)
                            .background {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(.white)
                            }
                            .shadow(radius: 5)
                            .padding(10)
                    }
                }

                if !viewModel.images.isEmpty {
                    Button(action: viewModel.clearImages) {
                        Image(systemName: "trash")
                    }
                }
            }
        }
    }
}
