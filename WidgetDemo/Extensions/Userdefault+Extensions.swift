//
//  Userdefault+Extensions.swift
//  Calculator
//
//  Created by 서창열 on 2022/05/12.
//

import Foundation
extension UserDefaults {
    var lastAdWatchTime:Date? {
        set {
            set(newValue?.timeIntervalSince1970, forKey: "lastAdWatchTime")
        }
        get {
            let value = double(forKey: "lastAdWatchTime")
            if value > 0 {
                return Date(timeIntervalSince1970: double(forKey: "lastAdWatchTime"))
            } else {
                return nil
            }
        }
    }
}
