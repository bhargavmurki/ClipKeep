//
//  Item.swift
//  ClipKeep
//
//  Created by Bhargav Murki on 8/8/24.
//

import Foundation
import AppKit
import SwiftData

@Model
final class Item {
    var kindRaw: String
    var content: String?
    var imageData: Data?
    var imagePasteboardTypeRaw: String?
    var fingerprint: String
    var createdAt: Date
    var source: String = "Clipboard"
    var copyCount: Int = 1

    var kind: ItemKind {
        get { ItemKind(rawValue: kindRaw) ?? .text }
        set { kindRaw = newValue.rawValue }
    }

    var imagePasteboardType: NSPasteboard.PasteboardType? {
        get {
            guard let imagePasteboardTypeRaw else { return nil }
            return NSPasteboard.PasteboardType(imagePasteboardTypeRaw)
        }
        set {
            imagePasteboardTypeRaw = newValue?.rawValue
        }
    }

    init(kind: ItemKind,
         content: String? = nil,
         imageData: Data? = nil,
         imagePasteboardType: NSPasteboard.PasteboardType? = nil,
         fingerprint: String,
         createdAt: Date = .init(),
         source: String = "Clipboard",
         copyCount: Int = 1) {
        self.kindRaw = kind.rawValue
        self.content = content
        self.imageData = imageData
        self.imagePasteboardTypeRaw = imagePasteboardType?.rawValue
        self.fingerprint = fingerprint
        self.createdAt = createdAt
        self.source = source
        self.copyCount = copyCount
    }
}

enum ItemKind: String, Codable {
    case text
    case image
}
