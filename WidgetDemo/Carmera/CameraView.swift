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
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

struct CameraView : View {
        
    
    let onCapture: (UIImage) -> Void
    @State var image: UIImage? = nil
    
    @State var exporse:Float = 0.0
    @State var focus:Float = 0.0
    @State var zoom:Float = 1.0
    
    @AppStorage("whiteBalance_red") var whiteBalance_red:Double = 1.5
    @AppStorage("whiteBalance_green") var whiteBalance_green:Double = 1.0
    @AppStorage("whiteBalance_blue") var whiteBalance_blue:Double = 3.0
    @State var images:[UIImage] = [] {
        didSet {
            animate.toggle()
        }
    }
    
    var imageViews:[Image] {
        images.map { image in
            return .init(uiImage: image)
        }
    }
    @State var presentImage:Bool = false
    
    @State var animate:Bool = false
    @AppStorage("isExtend") var isExtend:Bool = true
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
            }
        }
    }
    
    
    var sliders : some View {
        Group {
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
                                    "red" : Float(whiteBalance_red),
                                    "green" : Float(whiteBalance_green),
                                    "blue" : Float(whiteBalance_blue)
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
                                    "red" : Float(whiteBalance_red),
                                    "green" : Float(whiteBalance_green),
                                    "blue" : Float(whiteBalance_blue)
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
                                    "red" : Float(whiteBalance_red),
                                    "green" : Float(whiteBalance_green),
                                    "blue" : Float(whiteBalance_blue)
                                ]
                            ])
                        }
                }
            }

        }
    }
    var carmeraPreview: some View {
        GeometryReader { geo in
            var w:CGFloat {
                geo.size.width
            }
            var h:CGFloat {
                geo.size.width / 3 * 4
            }
            VStack {
                Spacer().frame(height:.safeAreaInsetTop + 1)
                BannerAdView(sizeType: .AdSizeBanner, padding: .zero)
                    .background(.clear)
                    .border(.primary)
                
                _CameraView { image in
                    images.append(image)
                    saveImage(image: image, present: false)
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
                }.frame(height: 40)
                ScrollView {
                    imageScrollView
                    sliders
                }.padding(20)
            }
        }.background(.background)
        
        
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
