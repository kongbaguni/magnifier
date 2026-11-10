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


// The SDK callback returns an ad that is only accessed after a MainActor hop.
private struct RewardedAdTransfer: @unchecked Sendable {
    let ad: RewardedAd?
}

@MainActor
class GoogleAd : NSObject {
    
    var interstitial:RewardedAd? = nil
    func requestTrackingAuthorization(complete: @escaping @MainActor @Sendable () -> Void) {
        ATTrackingManager.requestTrackingAuthorization { status in
            print("google ad tracking status : \(status)")
            Task { @MainActor in
                complete()
            }
        }
    }
    
    private func loadAd(complete: @escaping @MainActor @Sendable (_ isSucess: Bool) -> Void) {
        let request = Request()
        requestTrackingAuthorization { [weak self] in
            RewardedAd.load(with: rewardedid, request: request) { [weak self] ad, error in
                let transfer = RewardedAdTransfer(ad: ad)
                let errorDescription = error?.localizedDescription
                Task { @MainActor [weak self, transfer] in
                    guard let self else { return }
                    if let errorDescription {
                        print("google ad load error : \(errorDescription)")
                    }
                    transfer.ad?.fullScreenContentDelegate = self
                    self.interstitial = transfer.ad
                    complete(transfer.ad != nil)
                }
            }
        }
    }
    
    var callback: @MainActor @Sendable (_ isSucess: Bool, _ time: TimeInterval?) -> Void = { _, _ in }
    
    func showAd(complete: @escaping @MainActor @Sendable (_ isSucess: Bool, _ time: TimeInterval?) -> Void) {
        callback = complete
        NotificationCenter.default.post(name: .adLoadingStart, object: nil)
        loadAd { [weak self] isSucess in
            NotificationCenter.default.post(name: .adLoadingFinish, object: nil)
            if isSucess == false {
                complete(true, nil)
                return
            }
            UserDefaults.standard.lastAdWatchTime = Date()
                        
            if let vc = UIApplication.shared.lastViewController {
                self?.interstitial?.present(from: vc, userDidEarnRewardHandler: {})
            }
        }
    }
    
}

extension GoogleAd : FullScreenContentDelegate {
    //광고 실패
    nonisolated func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("google ad \(#function)")
        print(error.localizedDescription)
        Task { @MainActor [weak self] in
            self?.callback(true, nil)
        }
    }
    nonisolated func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        print("google ad \(#function)")
    }
    //광고시작
    nonisolated func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        print("google ad \(#function)")
    }
    //광고 종료
    nonisolated func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("google ad \(#function)")
        Task { @MainActor [weak self] in
            self?.callback(true, nil)
        }
    }
}

struct GoogleAdBannerView: UIViewRepresentable {
    let type:BannerAdView.SizeType
    let delegate = GoogleAdBannerViewDelegate()
    @State var isRegObserver = false
    func makeUIView(context: Context) -> BannerView {
        let bannerView:BannerView = .makeView(sizeType: type)
        bannerView.adUnitID = bannerGaId
        bannerView.rootViewController = UIApplication.shared.lastViewController
        return bannerView
    }
  
    @MainActor
    func updateUIView(_ uiView: BannerView, context: Context) {
        uiView.load(Request())
        print("GADBannerViewDelegate \(#function) \(#line)")
        NotificationCenter.default.post(name: .adBannerLoadingStart, object: nil)
        uiView.delegate = delegate
        if isRegObserver == false  {
            NotificationCenter.default.addObserver(forName: .adBannerLoadingFail, object: nil, queue: nil) { [weak uiView] _ in
                Task { @MainActor [weak uiView] in
                    do {
                        try await Task.sleep(for: .seconds(10))
                    } catch {
                        return
                    }
                    guard let uiView else { return }
                    uiView.load(Request())
                    NotificationCenter.default.post(name: .adBannerLoadingStart, object: nil)
                }
            }
            NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { [weak uiView] _ in
                Task { @MainActor [weak uiView] in
                    guard let uiView else { return }
                    uiView.load(Request())
                    NotificationCenter.default.post(name: .adBannerLoadingStart, object: nil)
                }
            }
            DispatchQueue.main.async {
                isRegObserver = true
            }
        }
    }
}

class GoogleAdBannerViewDelegate : NSObject, BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
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
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        print("GADBannerViewDelegate \(#function) \(#line)")
        NotificationCenter.default.post(name: .adBannerLoadingFail, object: error)
    }
}
