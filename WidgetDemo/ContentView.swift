//
//  ContentView.swift
//  WidgetDemo
//
//  Created by Changyeol Seo on 2023/06/28.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    @State var zoom:CGFloat = 1.0
    @State var log = LimitedArray<String>(limit: 20)
    @State var image:Image = Image("cat")
    @State var isPresentedImageView = false

    @State var isAddObserver = false
    private func addObserver() {
        if(isAddObserver) {
            return
        }
        isAddObserver = true
        log.append("addOberver");
        NotificationCenter.default.addObserver(forName: .carmeraPreviewLog, object: nil, queue: nil) { noti in
            if let notilog = noti.object as? String {
                log.append(notilog)
            }
        }
        
        NotificationCenter.default.addObserver(forName: .carmeraPhotoOutput, object: nil, queue: nil) { noti in
            if let img = noti.object as? UIImage {
                image = Image(uiImage: img)
            }
        }
        NotificationCenter.default.addObserver(forName: .carmeraZoomChanged, object: nil, queue: nil) { noti in
            if let zoomFector = noti.object as? CGFloat {
                zoom = zoomFector
            }
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { noti in
            WidgetCenter.shared.reloadAllTimelines()
        }
        
        NotificationCenter.default.addObserver(forName: .carmeraTakePhotoSaveFinish, object: nil, queue: nil) { noti in
            image = AppGroup.savedImage ?? Image("cat")
            if let img = noti.object as? UIImage {
                image = Image(uiImage: img)
            }
            isPresentedImageView = true
            
        }
    }
    
    var body: some View {
        ZStack {
            CameraPreview()

            VStack{
                Spacer()
                Text("zoom : \(String(format: "%.2f",zoom))")
                    .shadow(radius: 10)
                HStack {
                    ButtonView(action: {
                        isPresentedImageView = true

                    }, titleImage: image, titleText: nil)
//                    ToggleSliderButton(
//                        titleOn: Image(systemName: "plusminus.circle.fill"),
//                        titleOff: Image(systemName: "plusminus.circle"),
//                        onToggleBtn: { isOn in
//                            NotificationCenter.default.post(name: .carmeraSettingChange, object: nil, userInfo:
//                                ["isOnExposureManual":isOn]
//                            )
//                            print(isOn)
//                        
//                    }, onChangeSlider: { value in
//                        print(value)
//                        NotificationCenter.default.post(name: .carmeraSettingChange, object:nil, userInfo:
//                            ["exposureManualValue":value]
//                        )
//                        
//                    })
                    Spacer()
                    ButtonView(action: {
                        NotificationCenter.default.post(name: .carmeraTakePhoto, object: zoom)
                    }, titleImage: Image("carmera"), titleText: nil)
                }

            }
            .padding(.leading, 5)
            .padding(.trailing, 5)
            .padding(.bottom,
                     (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.bottom ?? 0)
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear{
            addObserver()
            image = AppGroup.savedImage ?? Image("cat")
        }
        .sheet(isPresented: $isPresentedImageView) {
            ImageView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
