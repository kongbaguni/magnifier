//
//  LimitedArray.swift
//  WidgetDemo
//
//  Created by Changyeol Seo on 2023/06/28.
//

import Foundation
import SwiftUI

struct LimitedArray<Element> {
    private var elements: [Element] = []
    private let limit: Int
    
    init(limit: Int) {
        self.limit = limit
    }
    
    mutating func append(_ element: Element) {
        if elements.count >= limit {
            elements.removeFirst()
        }
        elements.append(element)
    }
    
    subscript(index: Int) -> Element {
        return elements[index]
    }
    
    var count: Int {
        return elements.count
    }
}
