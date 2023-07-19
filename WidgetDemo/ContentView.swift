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
import UserMessagingPlatform

struct ContentView: View {
    init() {
        GoogleAd().requestTrackingAuthorization {[self] in
            ump()
        }
    }
    func ump() {
        func loadForm() {
          // Loads a consent form. Must be called on the main thread.
            UMPConsentForm.load { form, loadError in
                if loadError != nil {
                  // Handle the error
                } else {
                    // Present the form. You can also hold on to the reference to present
                    // later.
                    if UMPConsentInformation.sharedInstance.consentStatus == UMPConsentStatus.required {
                        form?.present(
                            from: UIApplication.topViewController!,
                            completionHandler: { dismissError in
                                if UMPConsentInformation.sharedInstance.consentStatus == UMPConsentStatus.obtained {
                                    // App can start requesting ads.
                                }
                                // Handle dismissal by reloading form.
                                loadForm();
                            })
                    } else {
                        // Keep the form available for changes to user consent.
                    }
                    
                }

            }
        }
        // Create a UMPRequestParameters object.
        let parameters = UMPRequestParameters()
        // Set tag for under age of consent. Here false means users are not under age.
        parameters.tagForUnderAgeOfConsent = false
        #if DEBUG
        let debugSettings = UMPDebugSettings()
//        debugSettings.testDeviceIdentifiers = ["78ce88aff302a5f4dfa5226a766c0b5a"]
        debugSettings.geography = UMPDebugGeography.EEA
        parameters.debugSettings = debugSettings
        #endif
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(
            with: parameters,
            completionHandler: { error in
                if error != nil {
                    // Handle the error.
                    print(error!.localizedDescription)
                } else {
                    let formStatus = UMPConsentInformation.sharedInstance.formStatus
                    if formStatus == UMPFormStatus.available {
                      loadForm()
                    }

                }
            })
    }
    let ad = GoogleAd()
    @State var zoom:CGFloat = 1.0
    @State var log = LimitedArray<String>(limit: 20)
    @State var image:Image = Image("cat")
    @State var isPresentedImageView = false

    @State var isAddObserver = false
    @State var isHaveCarmeraPermission = true
    private func addObserver() {
        if(isAddObserver) {
            return
        }
        isAddObserver = true
        log.append("addOberver");
        GADMobileAds.sharedInstance().start(completionHandler: nil)
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

    var controlPannel : some View {
        Group {
            Text("zoom : \(String(format: "%.2f",zoom))")
                .foregroundColor(.white)
                .shadow(radius: 20)
            HStack {
                ButtonView(action: {
                    ad.showAd { _, _ in
                        isPresentedImageView = true
                    }
                    
                    
                }, titleImage: image, titleText: nil)
//                Spacer()
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
                if isHaveCarmeraPermission {
                    ButtonView(action: {
                        NotificationCenter.default.post(name: .carmeraTakePhoto, object: zoom)
                    }, titleImage: Image("carmera"), titleText: nil)
                }
            }
        }
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                if isHaveCarmeraPermission {
                    CameraPreview()
                    .frame(width: proxy.size.width, height: proxy.size.height)
//                    .fixedSize()
                }
                else {
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
            addObserver()
            image = AppGroup.savedImage ?? Image("cat")
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            isHaveCarmeraPermission = status != .denied && status != .restricted
            
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
