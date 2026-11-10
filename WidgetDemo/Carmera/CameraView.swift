//
//  CameraView.swift
//  ucmIos
//
//  Created by Changyeol Seo on 10/29/24.
//

import SwiftUI
import AVFoundation

extension Notification.Name {
    /** 카메라 호출 */
    static let callCamera = Notification.Name("callCamera")
    /** 사진촬영 버튼 누름 */
    static let cameraCapture = Notification.Name("cameraCapture")
    /** 크롭 완료 */
    static let cropdone = Notification.Name("cropdone")
    /** 사진 업로드 완료 */
    static let photoUploadFinished = Notification.Name("photoUploadFinished")

    /** 카메라 설정값 조절*/
    static let cameraSettingChange = Notification.Name("cameraSettingChange")
}

fileprivate struct _CameraView: UIViewControllerRepresentable {
    let onCapture: (UIImage) -> Void

    func makeUIViewController(context: Context) -> CameraViewController {
        let viewController = CameraViewController()
        viewController.setupCamera(onCapture: onCapture)
        return viewController
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

struct CameraView: View {
    @StateObject private var viewModel: CameraViewModel

    init(onCapture: @escaping (UIImage) -> Void) {
        _viewModel = StateObject(
            wrappedValue: CameraViewModel(onCapture: onCapture)
        )
    }

   

    @ViewBuilder
    private var lensSelectView: some View {
        HStack {
            if #available(iOS 26.0, *) {
                LensSelectView(viewModel: viewModel)
                    .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 20))
            } else {
                LensSelectView(viewModel: viewModel)
            }
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
    
   
    
    @ViewBuilder
    private var controllerView: some View {
        VStack {
            HStack {
                Button(action: viewModel.capturePhoto) {
                    Image(systemName: "camera.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                }

                lensSelectView
                Toggle(isOn: $viewModel.isExtended) {}
            }
            .frame(height: 40)


            ImageScrollView(viewModel: viewModel)

            SliderSectionView(viewModel: viewModel)

            #if !DEBUG
            BannerAdView(sizeType: .AdSizeBanner, padding: .zero)
                .background(.clear)
                .border(.primary)
                .padding(.bottom, .safeAreaInsetBottom + 0.5)
            #else
            Spacer().frame(height: .safeAreaInsetBottom)
            #endif
        }
        .padding(10)
        .background(.background.opacity(0.5))
    }

    @ViewBuilder
    private var cameraPreview: some View {
        GeometryReader { proxy in
            ZStack (alignment: .bottomTrailing) {
            _CameraView { image in
                viewModel.handleCapturedImage(image)
            }
            .background(Color.gray)

                
                Group {
                    if #available(iOS 26.0, *) {
                        controllerView
                            .glassEffect(.clear, in: .rect(cornerRadius: 0))
                    } else {
                        controllerView
                    }
                }.frame(
                    width: proxy.size.width > proxy.size.height ? proxy.size
                        .width / 2 : proxy.size.width)
            }
        }
        .background(.background)
    }

    @ViewBuilder
    var body: some View {
        cameraPreview
            .animation(.easeInOut, value: viewModel.images.count)
            .sheet(isPresented: $viewModel.isPresentingImage) {
                ImageView()
            }
            .onAppear(perform: viewModel.configureCamera)
            .onReceive(NotificationCenter.default.publisher(for: .cameraSettingChange)) {
                viewModel.handleCameraSettingChange($0)
            }
    }
}

#Preview {
    CameraView { _ in }
}
