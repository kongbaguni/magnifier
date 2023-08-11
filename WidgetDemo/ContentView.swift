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
import ActivityIndicatorView

struct ContentView: View {
    enum AdAlertAfterAction {
        case imageView
        case takePicture
    }
    let ad = GoogleAd()
    @AppStorage("adWatchPoint") var adWatchPoint = 0
    @State var zoom:CGFloat = 1.0
    @State var log = LimitedArray<String>(limit: 20)
    @State var image:Image = Image("cat")
    @State var isPresentedImageView = false

    @State var isHaveCarmeraPermission = true

    @State var borderColor:Color = .clear
    @State var longPressBeganDate:Date? = nil
    @State var isLoading = false
    @State var adAlertConfirm = false
    @State var adAlertAfterAction:AdAlertAfterAction? = nil
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
                Text("Point").font(.caption).foregroundColor(.white)
                Text(":")
                Text("\(adWatchPoint)").font(.caption).bold().foregroundColor(.yellow)
            }
            .padding(5)
            .background(Color.gray.opacity(0.8))
            .cornerRadius(20)


            HStack {
                ButtonView(action: {
                    if isLoading {
                        return
                    }
                    if adWatchPoint >= 10 {
                        isPresentedImageView = true
                        adWatchPoint -= 10
                    }
                    else {
                        adAlertConfirm = true
                        adAlertAfterAction = .imageView
                    }
                }, titleImage: image, titleText: nil)
                Spacer()
                if isHaveCarmeraPermission {
                    ButtonView(action: {
                        if isLoading {
                            return
                        }
                        if adWatchPoint >= 1 {
                            NotificationCenter.default.post(name: .carmeraTakePhoto, object: zoom)
                            adWatchPoint -= 1
                        } else {
                            adAlertConfirm = true
                            adAlertAfterAction = .takePicture
                        }
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
        .onReceive(NotificationCenter.default.publisher(for: .adLoadingStart)) { noti in
            isLoading = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .adLoadingFinish)) { noti in
            isLoading = false
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
                if isLoading {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ActivityIndicatorView(isVisible: $isLoading, type: .default())
                                .frame(width:50, height:50)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        Spacer()
                    }
                    .background(Color.black.opacity(0.8))
                }
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
        .alert(isPresented: $adAlertConfirm) {
            Alert(title: Text("adAlertConfirm_title"),
                  primaryButton: .default(Text("confirm"), action: {
                ad.showAd { _, _ in
                    adWatchPoint += 100
                    switch adAlertAfterAction {
                        case .imageView:
                            isPresentedImageView = true
                            adWatchPoint -= 10
                        case .takePicture:
                            NotificationCenter.default.post(name: .carmeraTakePhoto, object: zoom)
                            adWatchPoint -= 1
                    }
                    
                }
            }), secondaryButton: .cancel())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
