//
//  BannerAdView.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/19.
//

import SwiftUI
import GoogleMobileAds
import ActivityIndicatorView

struct BannerAdView: View {
    public enum SizeType {
        /** iPhone and iPod Touch ad size. Typically 320x50.*/
        case AdSizeBanner
        /** Taller version of AdSizeBanner. Typically 320x100.*/
        case AdSizeLargeBanner
        /** Medium Rectangle size for the iPad (especially in a UISplitView's left pane). Typically 300x250.*/
        case AdSizeMediumRectangle
        /** Full Banner size for the iPad (especially in a UIPopoverController or in UIModalPresentationFormSheet). Typically 468x60.*/
        case AdSizeFullBanner
        /** Leaderboard size for the iPad. Typically 728x90*/
        case AdSizeLeaderboard
        /** Skyscraper size for the iPad. Mediation only. AdMob/Google does not offer this size. Typically 120x600*/
        case AdSizeSkyscraper
    }
    let sizeType:SizeType
    
    let padding:UIEdgeInsets
    
    private var bannerSize:CGSize {
        switch sizeType {
        case .AdSizeBanner:
            return .init(width: 320, height: 50)
        case .AdSizeLargeBanner:
            return .init(width: 320, height: 100)
        case .AdSizeMediumRectangle:
            return .init(width: 300, height: 250)
        case .AdSizeFullBanner:
            return .init(width: 468, height: 60)
        case .AdSizeLeaderboard:
            return .init(width: 728, height: 90)
        case .AdSizeSkyscraper:
            return .init(width: 120, height: 600)
        }
    }
    
    @State var loading:Bool = true
    
    let gad = GoogleAd()
    var body: some View {
        ZStack {
            GoogleAdBannerView(type: sizeType)
            ActivityIndicatorView(isVisible: $loading, type: .gradient([.red,.orange,.yellow,.gray,.blue,.purple]))
                .frame(width: 30, height: 30)
                .shadow(color:.primary, radius: 20)
        }
        .frame(width: bannerSize.width, height: bannerSize.height, alignment: .center)
        .background(Color.primary.opacity(0.2))
        .padding(.top,padding.top)
        .padding(.bottom,padding.bottom)
        .padding(.leading, padding.left)
        .padding(.trailing, padding.right)
        .onReceive(NotificationCenter.default.publisher(for: .adBannerLoadingStart)) { noti in
            loading = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .adBannerLoadingFinish)) { noti in
            loading = false
        }
        .onReceive(NotificationCenter.default.publisher(for: .adBannerLoadingFail)) { noti in
            loading = false
        }
        
    }
    
    init(sizeType:SizeType, padding:UIEdgeInsets = .zero) {
        self.sizeType = sizeType
        self.padding = padding
    }
}

extension BannerView {
    static func makeView(sizeType:BannerAdView.SizeType)->BannerView {
        switch sizeType {
            case .AdSizeBanner:
                return BannerView(adSize : AdSizeBanner)
            case .AdSizeLargeBanner:
                return BannerView(adSize : AdSizeLargeBanner)
            case .AdSizeMediumRectangle:
                return BannerView(adSize : AdSizeMediumRectangle)
            case .AdSizeFullBanner:
                return BannerView(adSize : AdSizeFullBanner)
            case .AdSizeLeaderboard:
                return BannerView(adSize : AdSizeLeaderboard)
            case .AdSizeSkyscraper:
                return BannerView(adSize : AdSizeSkyscraper)
        }
    }
}
