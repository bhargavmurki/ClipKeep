//
//  Item.swift
//  ClipKeep
//
//  Created by Bhargav Murki on 8/8/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var content: String
    var createdAt: Date
    var source: String = "Clipboard"
    var copyCount: Int = 1

    init(content: String, createdAt: Date = .init(), source: String = "Clipboard", copyCount: Int = 1) {
        self.content = content
        self.createdAt = createdAt
        self.source = source
        self.copyCount = copyCount
    }
}
