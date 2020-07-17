//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

import UIKit

// ImageEditorContents represents a snapshot of canvas
// state.
//
// Instances of ImageEditorContents should be treated
// as immutable, once configured.
public class ImageEditorContents: NSObject {
    public typealias ItemMapType = OrderedDictionary<String, ImageEditorItem>

    // This represents the current state of each item,
    // a mapping of [itemId : item].
    var itemMap = ItemMapType()

    // Used to create an initial, empty instances of this class.
    override public init() {}

    // Used to clone copies of instances of this class.
    public init(itemMap: ItemMapType) {
        self.itemMap = itemMap
    }

    // Since the contents are immutable, we only modify copies
    // made with this method.
    public func clone() -> ImageEditorContents {
        return ImageEditorContents(itemMap: itemMap)
    }

    @objc
    public func item(forId itemId: String) -> ImageEditorItem? {
        return itemMap[itemId]
    }

    @objc
    public func append(item: ImageEditorItem) {
        Logger.debug("\(item.itemId)")

        itemMap.appendValue(item, forKey: item.itemId)
    }

    @objc
    public func replace(item: ImageEditorItem) {
        Logger.debug("\(item.itemId)")

        itemMap[item.itemId] = item
    }

    @objc
    public func remove(item: ImageEditorItem) {
        Logger.debug("\(item.itemId)")

        itemMap.removeValue(forKey: item.itemId)
    }

    @objc
    public func remove(itemId: String) {
        Logger.debug("\(itemId)")

        itemMap.removeValue(forKey: itemId)
    }

    @objc
    public func itemCount() -> Int {
        return itemMap.count
    }

    @objc
    public func items() -> [ImageEditorItem] {
        return itemMap.values
    }

    @objc
    public func itemIds() -> [String] {
        return itemMap.keys
    }
}
