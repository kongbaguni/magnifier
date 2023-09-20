//
//  CGPoint+Extensions.swift
//  readingGlasses
//
//  Created by Changyeol Seo on 2023/09/20.
//

import Foundation
extension CGPoint {
    static func + (left:CGPoint, right:CGPoint) -> CGPoint {
        .init(x: left.x + right.x, y: left.y + right.y)
    }
    
    static func - (left:CGPoint, right:CGPoint) -> CGPoint {
        .init(x: left.x - right.x, y: left.y - right.y)
    }
}
