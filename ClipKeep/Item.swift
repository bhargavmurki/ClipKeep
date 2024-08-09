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
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
