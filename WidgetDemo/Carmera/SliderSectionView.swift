//
//  SliderSectionView.swift
//  readingGlasses
//
//  Created by 서창열 on 11/10/26.
//

import SwiftUI

struct SliderSectionView: View {
    @ObservedObject var viewModel: CameraViewModel

    var body: some View {
        let types = viewModel.isExtended ? CameraViewModel.SliderType.allCases : [
            .zoom,
            .focus
        ]

        ForEach(types, id: \.self) { type in
            makeSlider(type: type)
        }
    }

    @ViewBuilder
    private func makeSlider(type: CameraViewModel.SliderType) -> some View {
        HStack {
            switch type {
            case .zoom:
                Image(systemName: "plus.magnifyingglass")
                Slider(value: $viewModel.zoom, in: 0.5...20.0)
            case .focus:
                Image(systemName: "camera.metering.center.weighted")
                Slider(value: $viewModel.focus, in: 0.0...1.0)
            case .exposure:
                Image(systemName: "camera.aperture")
                Slider(value: $viewModel.exposure, in: -3.0...3.0)
            case .whiteBalanceRed:
                Image(systemName: "camera.filters")
                    .foregroundColor(.red)
                Slider(value: $viewModel.whiteBalanceRed, in: 1.0...4.0)
            case .whiteBalanceGreen:
                Image(systemName: "camera.filters")
                    .foregroundColor(.green)
                Slider(value: $viewModel.whiteBalanceGreen, in: 1.0...4.0)
            case .whiteBalanceBlue:
                Image(systemName: "camera.filters")
                    .foregroundColor(.blue)
                Slider(value: $viewModel.whiteBalanceBlue, in: 1.0...4.0)
            }
        }
    }
}
