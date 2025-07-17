//
//  AppGroup.swift
//  WidgetDemo
//
//  Created by Changyeol Seo on 2023/06/28.
//

import Foundation
import UIKit
import WidgetKit
import SwiftUI

struct AppGroup {
    
    enum ImageSize : CaseIterable {
        case small
        case medium
        case large
        var size:CGSize {
            switch self {
            case .small:
                return .init(width: 200, height: 200)
            case .medium:
                return .init(width: 400, height: 400)
            case .large:
                return .init(width: 600, height: 600)
            }
        }
        var url:URL? {
            let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Consts.AppGroupID)
            switch self {
            case .small:
                return appGroupURL?.appendingPathComponent(Consts.SaveTempImageSmall)
            case .medium:
                return appGroupURL?.appendingPathComponent(Consts.SaveTempImageMedium)
            case .large:
                return appGroupURL?.appendingPathComponent(Consts.SaveTempImageLarge)
            }
            return nil
        }
    }
    
    static func saveImage(image:UIImage) {
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Consts.AppGroupID) {
            for data in ImageSize.allCases {
                if let url = data.url {
                    if let img = image.resized(to: data.size ,contentMode: .scaleAspectFill) {
                        print("\(img.size)")
                        if let data = img.jpegData(compressionQuality: 0.7) {
                            do {
                                try data.write(to: url)
                            } catch {
                                print("이미지 저장 실패: \(error)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    static func getSavedUIImage (imageSize:ImageSize)->UIImage? {
        if let fileURL = imageSize.url {
            if let data = try? Data(contentsOf: fileURL) {
                return UIImage(data: data)
            }
        }
        return nil
    }
    
    static func getSavedImage(imageSize:ImageSize)->Image? {
        if let uiimage = getSavedUIImage(imageSize: imageSize) {
            
            return Image(uiImage: uiimage)
        }
        return nil
    }
}
