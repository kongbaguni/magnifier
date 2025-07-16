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
    static let cameraSettingChange =  Notification.Name("cameraSettingChange")
        
}

struct _CameraView: UIViewControllerRepresentable {
    let onCapture: (UIImage) -> Void
    func makeUIViewController(context: Context) -> CameraViewController {
        let vc = CameraViewController()
        vc.setupCamera(onCapture: onCapture)
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

struct CameraView : View {
        
    
    let onCapture: (UIImage) -> Void
    @State var image: UIImage? = nil
    
    @State var exporse:Float = 0.0
    @State var focus:Float = 0.0
    @State var zoom:Float = 1.0
    
    @State var whiteBalance_red:Float = 1.5
    @State var whiteBalance_green:Float = 1.0
    @State var whiteBalance_blue:Float = 3.0
    @State var images:[Image] = [] {
        didSet {
            animate.toggle()
        }
    }
    @State var presentImage:Bool = false
    
    @State var animate:Bool = false
    @AppStorage("isExtend") var isExtend:Bool = true
    func saveImage(image:Image) {
        if let img = image.getUIImage(newSize: .init(width:300 * 5, height:400 * 5)) {
            AppGroup.saveImage(image: img)
            presentImage = true
        }
    }
    
    var imageScrollView: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(0..<images.count, id:\.self) { idx in
                    Button {
                        saveImage(image: images[idx])
                    } label: {
                        images[idx]
                            .resizable()
                            .scaledToFit()
                            .frame(height:60)
                            .padding(5)
                            .background {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(.white)
                            }
                    }
                }
            }
        }
    }
    
    
    var sliders : some View {
        Group {
            HStack {
                Image(systemName: "camera.metering.center.weighted")
                Slider(value: $focus, in:0.0...1.0)
                    .onChange(of: focus) {  newValue in
                        print(newValue)
                        NotificationCenter.default.post(name: .cameraSettingChange , object: nil, userInfo: [
                            "focus" : newValue
                        ])
                    }
            }

            
            HStack {
                Image(systemName: "plus.magnifyingglass")
                
                Slider(value: $zoom, in:0.5...20.0)
                    .onChange(of: zoom) {  newValue in
                        print(newValue)
                        NotificationCenter.default.post(name: .cameraSettingChange, object: nil, userInfo: [
                            "zoom" : newValue
                        ])
                    }
            }
            if isExtend {
                HStack {
                    Image(systemName: "camera.aperture")
                    
                    Slider(value: $exporse, in:-3.0...3.0)
                        .onChange(of: exporse) {  newValue in
                            print(newValue)
                            NotificationCenter.default.post(name: .cameraSettingChange, object: nil, userInfo: [
                                "exporse" : newValue
                            ])
                        }
                }

                HStack {
                    Image(systemName: "camera.filters")
                        .foregroundColor(Color.red)
                    Slider(value: $whiteBalance_red, in:1.0...4.0)
                        .onChange(of: whiteBalance_red) { newValue in
                            NotificationCenter.default.post(name: .cameraSettingChange, object: nil, userInfo: [
                                "whiteBalence" : [
                                    "red" : whiteBalance_red,
                                    "green" : whiteBalance_green,
                                    "blue" : whiteBalance_blue
                                ]
                            ])
                        }
                }
                HStack {
                    Image(systemName: "camera.filters")
                        .foregroundColor(Color.green)
                    Slider(value: $whiteBalance_green, in:1.0...4.0)
                        .onChange(of: whiteBalance_green) { newValue in
                            NotificationCenter.default.post(name: .cameraSettingChange, object: nil, userInfo: [
                                "whiteBalence" : [
                                    "red" : whiteBalance_red,
                                    "green" : whiteBalance_green,
                                    "blue" : whiteBalance_blue
                                ]
                            ])
                        }
                }
                HStack {
                    Image(systemName: "camera.filters")
                        .foregroundColor(Color.blue)
                    Slider(value: $whiteBalance_blue, in:1.0...4.0)
                        .onChange(of: whiteBalance_blue) { newValue in
                            NotificationCenter.default.post(name: .cameraSettingChange, object: nil, userInfo: [
                                "whiteBalence" : [
                                    "red" : whiteBalance_red,
                                    "green" : whiteBalance_green,
                                    "blue" : whiteBalance_blue
                                ]
                            ])
                        }
                }
            }

        }
    }
    var carmeraPreview: some View {
        ZStack {
            GeometryReader { geo in
                var w:CGFloat {
                    geo.size.width
                }
                var h:CGFloat {
                    geo.size.width / 3 * 4
                }
                VStack {
                    _CameraView { image in
                        images.append(.init(uiImage: image))
                    }
                    .frame(width: w, height: h)
                    .background(Color.gray)
                    HStack {
                        Spacer()
                        Button {
                            NotificationCenter.default.post(name: .cameraCapture, object: nil)
                        } label: {
                            Image(systemName: "camera.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                        Toggle(isOn: $isExtend) {
                            
                        }
                        Spacer()
                    }
                    ScrollView {
                        imageScrollView
                        
                        sliders
                    }.padding(20)
                        
                    BannerAdView(sizeType: .AdSizeLargeBanner, padding: .zero)
                        .padding(.bottom, .safeAreaInsetBottom)
                        .background(.clear)
                    
                }
            }
           
        }
        
    }
    
    var body: some View {
        ZStack {
            carmeraPreview
        }
        .animation(.easeInOut, value: animate)
        .sheet(isPresented: $presentImage, content: {
            ImageView()
        })
        .onAppear(perform: {
            NotificationCenter.default.post(name: .cameraSettingChange, object: nil, userInfo: [
                "focus" : focus,
                "exporse" : exporse,
                "zoom" : zoom,
                "whiteBalence" : [
                    "red" : whiteBalance_red,
                    "green" : whiteBalance_green,
                    "blue" : whiteBalance_blue
                ]
            ])
        })
       
        
    }
}



#Preview {
    CameraView{ image in
    }
}
