//
//  String+Extensions.swift
//  WidgetDemo
//
//  Created by Changyeol Seo on 2023/06/28.
//

import Foundation
extension String {
    func sendLog(withTag tag:String? = nil) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .carmeraPreviewLog, object: self);
            print("\(tag ?? ""): \(self)")
        }
    }
}
