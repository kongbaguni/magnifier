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

fileprivate struct _CameraView: UIViewControllerRepresentable {
    let onCapture: (UIImage) -> Void
    func makeUIViewController(context: Context) -> CameraViewController {
        let vc = CameraViewController()
        vc.setupCamera(onCapture: onCapture)
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        
    }
}

struct CameraView : View {
    enum SliderType : CaseIterable {
        case zoom
        case fucus
        case exporse
        case whiteBalance_red
        case whiteBalance_green
        case whiteBalance_blue
    }
    
    let onCapture: (UIImage) -> Void
    @State var image: UIImage? = nil
    
    @State var exporse:Float = 0.0
    @State var focus:Float = 0.0
    @State var zoom:Float = 1.0
    
    @AppStorage("whiteBalance_red") var whiteBalance_red:Double = 1.5
    @AppStorage("whiteBalance_green") var whiteBalance_green:Double = 1.0
    @AppStorage("whiteBalance_blue") var whiteBalance_blue:Double = 3.0
    @AppStorage("isExtend") var isExtend:Bool = true

    @State var images:[UIImage] = [] {
        didSet {
            animate.toggle()
        }
    }
        
    var sliderTypes:[SliderType] {
        if isExtend {
            return SliderType.allCases
        } else {
            return [ .zoom, .fucus ]
        }
    }
    
    var imageViews:[Image] {
        images.map { image in
            return .init(uiImage: image)
        }
    }
    @State var presentImage:Bool = false
    
    @State var animate:Bool = false
    
    func saveImage(image:UIImage, present:Bool) {
        AppGroup.saveImage(image: image)
        if present {
            presentImage = true
        }
    }
    
    var imageScrollView: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(0..<imageViews.count, id:\.self) { idx in
                    Button {
                        saveImage(image: images[idx], present: true)
                    } label: {
                        imageViews[idx]
                            .resizable()
                            .scaledToFit()
                            .frame(height:50)
                            .padding(5)
                            .background {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(.white)
                            }
                            .shadow(radius: 5)
                            .padding(10)
                    }
                }
                if images.count > 0 {
                    Button {
                        images.removeAll()
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
    }
    
    func makeSlider(type:SliderType) -> some View {
        HStack {
            switch type {
            case .zoom:
                Image(systemName: "plus.magnifyingglass")
                
                Slider(value: $zoom, in:0.5...20.0)
                    .onChange(of: zoom) {  newValue in
                        print(newValue)
                        NotificationCenter.default.post(name: .cameraSettingChange, object: nil, userInfo: [
                            "zoom" : newValue
                        ])
                    }
            case .fucus:
                Image(systemName: "camera.metering.center.weighted")
                Slider(value: $focus, in:0.0...1.0)
                    .onChange(of: focus) {  newValue in
                        print(newValue)
                        NotificationCenter.default.post(name: .cameraSettingChange , object: nil, userInfo: [
                            "focus" : newValue
                        ])
                    }
            case .exporse:
                Image(systemName: "camera.aperture")
                
                Slider(value: $exporse, in:-3.0...3.0)
                    .onChange(of: exporse) {  newValue in
                        print(newValue)
                        NotificationCenter.default.post(name: .cameraSettingChange, object: nil, userInfo: [
                            "exporse" : newValue
                        ])
                    }
            case .whiteBalance_red:
                Image(systemName: "camera.filters")
                    .foregroundColor(Color.red)
                Slider(value: $whiteBalance_red, in:1.0...4.0)
                    .onChange(of: whiteBalance_red) { newValue in
                        NotificationCenter.default.post(name: .cameraSettingChange, object: nil, userInfo: [
                            "whiteBalence" : [
                                "red" : Float(whiteBalance_red),
                                "green" : Float(whiteBalance_green),
                                "blue" : Float(whiteBalance_blue)
                            ]
                        ])
                    }
            case .whiteBalance_blue:
                Image(systemName: "camera.filters")
                    .foregroundColor(Color.green)
                Slider(value: $whiteBalance_green, in:1.0...4.0)
                    .onChange(of: whiteBalance_green) { newValue in
                        NotificationCenter.default.post(name: .cameraSettingChange, object: nil, userInfo: [
                            "whiteBalence" : [
                                "red" : Float(whiteBalance_red),
                                "green" : Float(whiteBalance_green),
                                "blue" : Float(whiteBalance_blue)
                            ]
                        ])
                    }
            case .whiteBalance_green:
                Image(systemName: "camera.filters")
                    .foregroundColor(Color.blue)
                Slider(value: $whiteBalance_blue, in:1.0...4.0)
                    .onChange(of: whiteBalance_blue) { newValue in
                        NotificationCenter.default.post(name: .cameraSettingChange, object: nil, userInfo: [
                            "whiteBalence" : [
                                "red" : Float(whiteBalance_red),
                                "green" : Float(whiteBalance_green),
                                "blue" : Float(whiteBalance_blue)
                            ]
                        ])
                    }
            }
        }
    }
    
    var sliders : some View {
        Group {
            ForEach(sliderTypes, id:\.self) { type in
                makeSlider(type: type)
            }
        }
    }
    
    var controllerView: some View {
        VStack {
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
            }.frame(height: 40)

            imageScrollView
            
            sliders // Fallback on earlier versions

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
//
    
    var carmeraPreview: some View {
        VStack {
            _CameraView { image in
                images.append(image)
                saveImage(image: image, present: false)
            }
            .background(Color.gray)

            
            if #available(iOS 26.0, *) {
                controllerView
                    .glassEffect(.clear, in: .rect(cornerRadius: 0))
            } else {
                controllerView // Fallback on earlier versions
            }
            

        }.background(.background)
        
        
    }
    
    var body: some View {
        carmeraPreview
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
        .onReceive(NotificationCenter.default.publisher(for: .cameraSettingChange)) { output in
            if let userInfo = output.userInfo as? [String : Any] {
                if let zoom = userInfo["zoom"] as? Float {
                    if self.zoom != zoom {
                        self.zoom = zoom
                    }
                }
            }
        }
        
        
    }
}



#Preview {
    CameraView{ image in
    }
}
