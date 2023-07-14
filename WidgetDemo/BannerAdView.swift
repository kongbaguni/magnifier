//
//  BannerAdView.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/19.
//

import SwiftUI
import GoogleMobileAds

struct BannerAdView: View {
    public enum SizeType {
        /** iPhone and iPod Touch ad size. Typically 320x50.*/
        case GADAdSizeBanner
        /** Taller version of GADAdSizeBanner. Typically 320x100.*/
        case GADAdSizeLargeBanner
        /** Medium Rectangle size for the iPad (especially in a UISplitView's left pane). Typically 300x250.*/
        case GADAdSizeMediumRectangle
        /** Full Banner size for the iPad (especially in a UIPopoverController or in UIModalPresentationFormSheet). Typically 468x60.*/
        case GADAdSizeFullBanner
        /** Leaderboard size for the iPad. Typically 728x90*/
        case GADAdSizeLeaderboard
        /** Skyscraper size for the iPad. Mediation only. AdMob/Google does not offer this size. Typically 120x600*/
        case GADAdSizeSkyscraper
    }
    let sizeType:SizeType
    
    let padding:UIEdgeInsets
    
    private var bannerSize:CGSize {
        switch sizeType {
        case .GADAdSizeBanner:
            return .init(width: 320, height: 50)
        case .GADAdSizeLargeBanner:
            return .init(width: 320, height: 100)
        case .GADAdSizeMediumRectangle:
            return .init(width: 300, height: 250)
        case .GADAdSizeFullBanner:
            return .init(width: 468, height: 60)
        case .GADAdSizeLeaderboard:
            return .init(width: 728, height: 90)
        case .GADAdSizeSkyscraper:
            return .init(width: 120, height: 600)
        }
    }
    
    @State var bannerView:GADBannerView? = nil
    let gad = GoogleAd()
    var body: some View {
        VStack {
            if let view = bannerView {
                GoogleAdBannerView(bannerView: view)
                    .frame(width: bannerSize.width, height: bannerSize.height, alignment: .center)
                    .padding(.top,padding.top)
                    .padding(.bottom,padding.bottom)
                    .padding(.leading, padding.left)
                    .padding(.trailing, padding.right)
            } else {
                Button {
                    initAdView()
                } label: {
                    Text("loading...")
                        .frame(width:bannerSize.width,height:bannerSize.height,alignment: .center)
                }

            }
        }
        .onAppear {
            initAdView()
        }
        
    }
    
    private func initAdView() {
        guard bannerView == nil else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            GoogleAd().requestTrackingAuthorization {
                DispatchQueue.main.async {
                    var bView:GADBannerView? {
                        switch sizeType {
                        case .GADAdSizeBanner:
                            return GADBannerView(adSize : GADAdSizeBanner)
                        case .GADAdSizeLargeBanner:
                            return GADBannerView(adSize : GADAdSizeLargeBanner)
                        case .GADAdSizeMediumRectangle:
                            return GADBannerView(adSize : GADAdSizeMediumRectangle)
                        case .GADAdSizeFullBanner:
                            return GADBannerView(adSize : GADAdSizeFullBanner)
                        case .GADAdSizeLeaderboard:
                            return GADBannerView(adSize : GADAdSizeLeaderboard)
                        case .GADAdSizeSkyscraper:
                            return GADBannerView(adSize : GADAdSizeSkyscraper)
                        }
                    }
                    bannerView = bView
                }
            }
        }
    }
}
