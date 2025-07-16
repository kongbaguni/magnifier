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
    @AppStorage("adWatchPoint") var adWatchPoint = 100
    @State var zoom:CGFloat = 1.0
    @State var log = LimitedArray<String>(limit: 20)
    @State var image:Image = Image("cat")
    @State var isPresentedImageView = false

    @State var isHaveCarmeraPermission = true

    @State var borderColor:Color = .clear
    @State var longPressBeganDate:Date? = nil
    @State var isLoading = false
    @State var adAlertConfirm = false
    @State var adAlertTitle:Text = Text("")
    @State var adAlertMsg:Text = Text("")
    @State var adAlertDesc:Text? = nil
    @State var adAlertAfterAction:AdAlertAfterAction? = nil
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                CameraView(onCapture: { image in
                    self.image = Image(uiImage: image)
                })
                .frame(width: proxy.size.width, height: proxy.size.height)
                .border(borderColor, width: 5)
                if isHaveCarmeraPermission == false {
                    CameraAccesDeninedView()
                }
                
                VStack {
                    Spacer()
                }
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

            MobileAds.shared.start(completionHandler: nil)
            image = AppGroup.savedImage ?? Image("cat")
            GoogleAdPrompt.promptWithDelay {
            }
        }
        .sheet(isPresented: $isPresentedImageView) {
            ImageView()
        }
        .alert(isPresented: $adAlertConfirm) {
            
            Alert(title: adAlertTitle,
                  message: adAlertMsg,
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
                        default:
                            break
                    }
                    
                }
            }), secondaryButton: .cancel())
        }
    }
}

#Preview {
    ContentView()
}
