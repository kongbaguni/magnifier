//
//  GoogleADViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/13.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

#if DEBUG
fileprivate let rewardedid = "ca-app-pub-3940256099942544/6978759866" // test ga id
fileprivate let bannerGaId = "ca-app-pub-3940256099942544/2934735716" // test ga id
#else
fileprivate let rewardedid = "ca-app-pub-7714069006629518/2824085521" // real ga id
fileprivate let bannerGaId = "ca-app-pub-7714069006629518/9265370795" // real ga id
#endif



class GoogleAd : NSObject {
    
    var interstitial:GADRewardedAd? = nil
    func requestTrackingAuthorization(complete:@escaping()->Void) {
        ATTrackingManager.requestTrackingAuthorization { status in
            print("google ad tracking status : \(status)")
            complete()
        }
    }
    
    private func loadAd(complete:@escaping(_ isSucess:Bool)->Void) {
        let request = GADRequest()
        requestTrackingAuthorization {
            GADRewardedAd.load(withAdUnitID: rewardedid, request: request) { [weak self] ad, error in
                if let err = error {
                    print("google ad load error : \(err.localizedDescription)")
                }
                ad?.fullScreenContentDelegate = self
                self?.interstitial = ad
                complete(ad != nil)
            }
        }
    }
    
    var callback:(_ isSucess:Bool, _ time:TimeInterval?)->Void = { _,_ in}
    
    func showAd(complete:@escaping(_ isSucess:Bool, _ time:TimeInterval?)->Void) {
        callback = complete
        NotificationCenter.default.post(name: .adLoadingStart, object: nil)
        loadAd { [weak self] isSucess in
            NotificationCenter.default.post(name: .adLoadingFinish, object: nil)
            if isSucess == false {
                DispatchQueue.main.async {
                    complete(true,nil)
                }
                return
            }
            UserDefaults.standard.lastAdWatchTime = Date()
                        
            if let vc = UIApplication.shared.lastViewController {
                self?.interstitial?.present(fromRootViewController: vc, userDidEarnRewardHandler: {
                    
                })
            }
        }
    }
    
}

extension GoogleAd : GADFullScreenContentDelegate {
    //광고 실패
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("google ad \(#function)")
        print(error.localizedDescription)
        DispatchQueue.main.async {
            self.callback(true, nil)
        }
    }
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        print("google ad \(#function)")
    }
    //광고시작
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("google ad \(#function)")
    }
    //광고 종료
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("google ad \(#function)")        
        DispatchQueue.main.async {
            self.callback(true, nil)
        }
    }
}

struct GoogleAdBannerView: UIViewRepresentable {
    let type:BannerAdView.SizeType
    let delegate = GoogleAdBannerViewDelegate()
    @State var isRegObserver = false
    func makeUIView(context: Context) -> GADBannerView {
        let bannerView:GADBannerView = .makeView(sizeType: type)
        bannerView.adUnitID = bannerGaId
        bannerView.rootViewController = UIApplication.shared.lastViewController
        return bannerView
    }
  
    func updateUIView(_ uiView: GADBannerView, context: Context) {
        uiView.load(GADRequest())
        print("GADBannerViewDelegate \(#function) \(#line)")
        NotificationCenter.default.post(name: .adBannerLoadingStart, object: nil)
        uiView.delegate = delegate
        if isRegObserver == false  {
            NotificationCenter.default.addObserver(forName: .adBannerLoadingFail, object: nil, queue: nil) { noti in
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
                    uiView.load(GADRequest())
                    NotificationCenter.default.post(name: .adBannerLoadingStart, object: nil)
                }
            }
            NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { noti in
                uiView.load(GADRequest())
                NotificationCenter.default.post(name: .adBannerLoadingStart, object: nil)
            }
            DispatchQueue.main.async {
                isRegObserver = true
            }            
        }
    }
}

class GoogleAdBannerViewDelegate : NSObject, GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("GADBannerViewDelegate \(#function) \(#line)")
        NotificationCenter.default.post(name: .adBannerLoadingFinish, object: nil)
    }
//    func bannerViewDidRecordClick(_ bannerView: GADBannerView) {
//
//    }
//    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
//
//    }
//    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
//
//    }
//    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
//
//    }
//    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
//
//    }
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("GADBannerViewDelegate \(#function) \(#line)")
        NotificationCenter.default.post(name: .adBannerLoadingFail, object: error)
    }
}
