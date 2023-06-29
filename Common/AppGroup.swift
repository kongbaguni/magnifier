//
//  AppGroup.swift
//  WidgetDemo
//
//  Created by Changyeol Seo on 2023/06/28.
//

import Foundation
import UIKit

struct AppGroup {
    static func saveImage(image:UIImage) {
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Consts.AppGroupID) {
            let fileURL = appGroupURL.appendingPathComponent("sharedImage.jpg")
            
            if let img = image.resized(to: .init(width: 400, height: 400),contentMode: .scaleAspectFill) {
                print("\(img.size)")
                if let data = img.jpegData(compressionQuality: 0.7) {
                    do {
                        try data.write(to: fileURL)
                    } catch {
                        print("이미지 저장 실패: \(error)")
                    }
                }
            }
        }
    }
    static var savedImage:UIImage? {
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Consts.AppGroupID) {
            let fileURL = appGroupURL.appendingPathComponent("sharedImage.jpg")
            if let data = try? Data(contentsOf: fileURL) {
                return UIImage(data: data)
            }
        }
        return nil
    }
}
