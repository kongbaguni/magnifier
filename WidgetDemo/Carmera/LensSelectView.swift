//
//  LensSelectView.swift
//  readingGlasses
//
//  Created by 서창열 on 11/10/26.
//

import SwiftUI

struct LensSelectView: View {
    @ObservedObject var viewModel: CameraViewModel

    var body: some View {
        HStack {
            ForEach(0..<2, id: \.self) { index in
                Button {
                    viewModel.lensSelection = index
                } label: {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            viewModel.lensSelection == index
                                ? .orange.opacity(0.8)
                                : .red.opacity(0.2)
                        )
                        .frame(width: 40, height: 40)
                        .overlay {
                            Text("\(index)")
                                .font(.body)
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    viewModel.lensSelection == index ? .primary : Color.clear,
                                    lineWidth: 2
                                )
                        }
                }
            }
        }
    }
}
