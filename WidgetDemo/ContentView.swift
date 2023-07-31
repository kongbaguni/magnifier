//
//  ContentView.swift
//  WidgetDemo
//
//  Created by Changyeol Seo on 2023/06/28.
//

import SwiftUI
import WidgetKit
import AVKit
import GoogleMobileAds

struct ContentView: View {
    let ad = GoogleAd()
    @State var zoom:CGFloat = 1.0
    @State var log = LimitedArray<String>(limit: 20)
    @State var image:Image = Image("cat")
    @State var isPresentedImageView = false

    @State var isHaveCarmeraPermission = true

    @State var borderColor:Color = .clear
    @State var longPressBeganDate:Date? = nil
    var controlPannel : some View {
        Group {
            HStack {
                Image(systemName:"magnifyingglass")
                    .resizable()
                    .scaledToFit()
                    .frame(width:30)
                    .foregroundColor(.white)
                    .padding(5)
                Text("\(String(format: "%.2f",zoom))x")
            }
            .padding(10)
            .background(Color.black.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(20)
            .shadow(radius: 20)

            HStack {
                ButtonView(action: {
                    ad.showAd { _, _ in
                        isPresentedImageView = true
                    }
                }, titleImage: image, titleText: nil)
                Spacer()
                if isHaveCarmeraPermission {
                    ButtonView(action: {
                        NotificationCenter.default.post(name: .carmeraTakePhoto, object: zoom)
                    }, titleImage: Image("carmera"), titleText: nil)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .cameraRequestPermissionGetResult)) { noti in
            DispatchQueue.main.async {
                let status = AVCaptureDevice.authorizationStatus(for: .video)
                isHaveCarmeraPermission = status == .authorized
                print(status)
                print("camera status : \(status)" )
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .carmeraPreviewLog)) { noti in
            if let notilog = noti.object as? String {
                log.append(notilog)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .carmeraTakePhotoSaveFinish)) { noti in
            image = AppGroup.savedImage ?? Image("cat")
            if let img = noti.object as? UIImage {
                image = Image(uiImage: img)
            }
            isPresentedImageView = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { noti in
            WidgetCenter.shared.reloadAllTimelines()
        }
        .onReceive(NotificationCenter.default.publisher(for: .carmeraZoomChanged)) { noti in
            if let zoomFector = noti.object as? CGFloat {
                zoom = zoomFector
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .carmeraPhotoOutput)) { noti in
            if let img = noti.object as? UIImage {
                image = Image(uiImage: img)
            }
        }
        
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                CameraPreview()
                .frame(width: proxy.size.width, height: proxy.size.height)
                .border(borderColor, width: 5)
                if isHaveCarmeraPermission == false {
                    CameraAccesDeninedView()
                }
                VStack {
                    BannerAdView(sizeType: .GADAdSizeBanner, padding: .zero)
                        .border(Color.black, width: 2)
                        .padding(.top, .safeAreaInsetTop)
                    Spacer()
                }
                VStack{
                    Spacer()
                    controlPannel
                }
                .padding(.leading, 5)
                .padding(.trailing, 5)
                .padding(.bottom, .safeAreaInsetBottom)
            }
        }

        .edgesIgnoringSafeArea(.all)
        .onAppear{
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            isHaveCarmeraPermission = status == .authorized

            GADMobileAds.sharedInstance().start(completionHandler: nil)
            image = AppGroup.savedImage ?? Image("cat")
            GoogleAdPrompt.promptWithDelay {
            }
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
