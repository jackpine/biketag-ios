//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import UIKit

// Used to represent undo/redo operations.
//
// Because the image editor's "contents" and "items"
// are immutable, these operations simply take a
// snapshot of the current contents which can be used
// (multiple times) to preserve/restore editor state.
private class ImageEditorOperation: NSObject {
    let operationId: String

    let contents: ImageEditorContents

    required init(contents: ImageEditorContents) {
        operationId = UUID().uuidString
        self.contents = contents
    }
}

// MARK: -

@objc
public protocol ImageEditorModelObserver: AnyObject {
    // Used for large changes to the model, when the entire
    // model should be reloaded.
    func imageEditorModelDidChange(before: ImageEditorContents,
                                   after: ImageEditorContents)

    // Used for small narrow changes to the model, usually
    // to a single item.
    func imageEditorModelDidChange(changedItemIds: [String])
}

// MARK: -

@objc
public class ImageEditorModel: NSObject {
    @objc
    public let srcImagePath: String

    @objc
    public let srcImageSizePixels: CGSize

    private var contents: ImageEditorContents

    private var transform: ImageEditorTransform

    private var undoStack = [ImageEditorOperation]()
    private var redoStack = [ImageEditorOperation]()

    var blurredSourceImage: CGImage?

    // We don't want to allow editing of images if:
    //
    // * They are invalid.
    // * We can't determine their size / aspect-ratio.
    @objc
    public required init(srcImagePath: String) throws {
        self.srcImagePath = srcImagePath

        // let srcFileName = (srcImagePath as NSString).lastPathComponent
        // let srcFileExtension = (srcFileName as NSString).pathExtension

        // Assume valid since it's captured in app.
        let mimeType = "image/jpeg"
        //        guard let mimeType = MIMETypeUtil.mimeType(forFileExtension: srcFileExtension) else {
        //            Logger.error("Couldn't determine MIME type for file.")
        //            throw ImageEditorError.invalidInput
        //        }
        //        guard MIMETypeUtil.isImage(mimeType),
        //            !MIMETypeUtil.isAnimated(mimeType) else {
        //            Logger.error("Invalid MIME type: \(mimeType).")
        //            throw ImageEditorError.invalidInput
        //        }
        let srcImageSizePixels = try Self.imageSize(for: URL(fileURLWithPath: srcImagePath), mimeType: mimeType)
        guard srcImageSizePixels.width > 0, srcImageSizePixels.height > 0 else {
            Logger.error("Couldn't determine image size.")
            throw ImageEditorError.invalidInput
        }
        self.srcImageSizePixels = srcImageSizePixels

        contents = ImageEditorContents()
        transform = ImageEditorTransform.defaultTransform(srcImageSizePixels: srcImageSizePixels)

        super.init()
    }

    class func imageSize(for imageUrl: URL, mimeType _: String) throws -> CGSize {
        guard let imageSourceRef = CGImageSourceCreateWithURL(imageUrl as CFURL, nil) else {
            assertionFailure("failed to create imageSourceRef")
            throw ImageEditorError.invalidInput
        }

        guard let props = CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, nil) else {
            assertionFailure("failed to create imageSourceRef")
            throw ImageEditorError.invalidInput
        }

        let properties = props as NSDictionary

        guard let height = properties.object(forKey: "PixelHeight") as? NSNumber else {
            assertionFailure("failed to create imageSourceRef")
            throw ImageEditorError.invalidInput
        }

        guard let width = properties.object(forKey: "PixelWidth") as? NSNumber else {
            assertionFailure("failed to create imageSourceRef")
            throw ImageEditorError.invalidInput
        }

        return CGSize(width: width.intValue, height: height.intValue)
    }

    public func renderOutput() -> UIImage? {
        return ImageEditorCanvasView.renderForOutput(model: self, transform: currentTransform())
    }

    public func currentTransform() -> ImageEditorTransform {
        return transform
    }

    @objc
    public func isDirty() -> Bool {
        if itemCount() > 0 {
            return true
        }
        return transform != ImageEditorTransform.defaultTransform(srcImageSizePixels: srcImageSizePixels)
    }

    @objc
    public func itemCount() -> Int {
        return contents.itemCount()
    }

    @objc
    public func items() -> [ImageEditorItem] {
        return contents.items()
    }

    @objc
    public func itemIds() -> [String] {
        return contents.itemIds()
    }

    @objc
    public func has(itemForId itemId: String) -> Bool {
        return item(forId: itemId) != nil
    }

    @objc
    public func item(forId itemId: String) -> ImageEditorItem? {
        return contents.item(forId: itemId)
    }

    @objc
    public func canUndo() -> Bool {
        return !undoStack.isEmpty
    }

    @objc
    public func canRedo() -> Bool {
        return !redoStack.isEmpty
    }

    @objc
    public func currentUndoOperationId() -> String? {
        guard let operation = undoStack.last else {
            return nil
        }
        return operation.operationId
    }

    // MARK: - Observers

    private var observers = [Weak<ImageEditorModelObserver>]()

    @objc
    public func add(observer: ImageEditorModelObserver) {
        observers.append(Weak(value: observer))
    }

    private func fireModelDidChange(before: ImageEditorContents,
                                    after: ImageEditorContents) {
        // We could diff here and yield a more narrow change event.
        for weakObserver in observers {
            guard let observer = weakObserver.value else {
                continue
            }
            observer.imageEditorModelDidChange(before: before,
                                               after: after)
        }
    }

    private func fireModelDidChange(changedItemIds: [String]) {
        // We could diff here and yield a more narrow change event.
        for weakObserver in observers {
            guard let observer = weakObserver.value else {
                continue
            }
            observer.imageEditorModelDidChange(changedItemIds: changedItemIds)
        }
    }

    // MARK: -

    @objc
    public func undo() {
        guard let undoOperation = undoStack.popLast() else {
            assertionFailure("Cannot undo.")
            return
        }

        let redoOperation = ImageEditorOperation(contents: contents)
        redoStack.append(redoOperation)

        let oldContents = contents
        contents = undoOperation.contents

        // We could diff here and yield a more narrow change event.
        fireModelDidChange(before: oldContents, after: contents)
    }

    @objc
    public func redo() {
        guard let redoOperation = redoStack.popLast() else {
            assertionFailure("Cannot redo.")
            return
        }

        let undoOperation = ImageEditorOperation(contents: contents)
        undoStack.append(undoOperation)

        let oldContents = contents
        contents = redoOperation.contents

        // We could diff here and yield a more narrow change event.
        fireModelDidChange(before: oldContents, after: contents)
    }

    @objc
    public func append(item: ImageEditorItem) {
        performAction({ oldContents in
            let newContents = oldContents.clone()
            newContents.append(item: item)
            return newContents
        }, changedItemIds: [item.itemId])
    }

    @objc
    public func replace(item: ImageEditorItem,
                        suppressUndo: Bool = false) {
        performAction({ oldContents in
            let newContents = oldContents.clone()
            newContents.replace(item: item)
            return newContents
        }, changedItemIds: [item.itemId],
                      suppressUndo: suppressUndo)
    }

    @objc
    public func remove(item: ImageEditorItem) {
        performAction({ oldContents in
            let newContents = oldContents.clone()
            newContents.remove(item: item)
            return newContents
        }, changedItemIds: [item.itemId])
    }

    @objc
    public func replace(transform: ImageEditorTransform) {
        self.transform = transform

        // The contents haven't changed, but this event prods the
        // observers to reload everything, which is necessary if
        // the transform changes.
        fireModelDidChange(before: contents, after: contents)
    }

    // MARK: - Temp Files

    private var temporaryFilePaths = [String]()

    @objc
    public func temporaryFilePath(withFileExtension fileExtension: String) -> String {
        assert(Thread.isMainThread)
        let url = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID().uuidString)!
            .appendingPathExtension(fileExtension)

        return url.path
    }

    deinit {
        assert(Thread.isMainThread)

        let temporaryFilePaths = self.temporaryFilePaths
        DispatchQueue.global(qos: .background).async {
            for filePath in temporaryFilePaths {
                do {
                    try FileManager.default.removeItem(atPath: filePath)
                } catch {
                    Logger.error("Could not delete temp file: \(filePath), error: \(error)")
                }
            }
        }
    }

    private func performAction(_ action: (ImageEditorContents) -> ImageEditorContents,
                               changedItemIds: [String]?,
                               suppressUndo: Bool = false) {
        if !suppressUndo {
            let undoOperation = ImageEditorOperation(contents: contents)
            undoStack.append(undoOperation)
            redoStack.removeAll()
        }

        let oldContents = contents
        let newContents = action(oldContents)
        contents = newContents

        if let changedItemIds = changedItemIds {
            fireModelDidChange(changedItemIds: changedItemIds)
        } else {
            fireModelDidChange(before: oldContents,
                               after: contents)
        }
    }

    // MARK: - Utilities

    // Returns nil on error.
    private class func crop(imagePath: String,
                            unitCropRect: CGRect) -> UIImage? {
        // TODO: Do we want to render off the main thread?
        assert(Thread.isMainThread)

        guard let srcImage = UIImage(contentsOfFile: imagePath) else {
            assertionFailure("Could not load image")
            return nil
        }
        let srcImageSize = srcImage.size
        // Convert from unit coordinates to src image coordinates.
        let cropRect = CGRect(x: round(unitCropRect.origin.x * srcImageSize.width),
                              y: round(unitCropRect.origin.y * srcImageSize.height),
                              width: round(unitCropRect.size.width * srcImageSize.width),
                              height: round(unitCropRect.size.height * srcImageSize.height))

        guard cropRect.origin.x >= 0,
            cropRect.origin.y >= 0,
            cropRect.origin.x + cropRect.size.width <= srcImageSize.width,
            cropRect.origin.y + cropRect.size.height <= srcImageSize.height else {
            assertionFailure("Invalid crop rectangle.")
            return nil
        }
        guard cropRect.size.width > 0,
            cropRect.size.height > 0 else {
            // Not an error; indicates that the user tapped rather
            // than dragged.
            Logger.info("Empty crop rectangle.")
            return nil
        }

        // Not currently supporting Alpha
        // let hasAlpha = NSData.hasAlpha(forValidImageFilePath: imagePath)
        let hasAlpha = false

        UIGraphicsBeginImageContextWithOptions(cropRect.size, !hasAlpha, srcImage.scale)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else {
            assertionFailure("context was unexpectedly nil")
            return nil
        }
        context.interpolationQuality = .high

        // Draw source image.
        let dstFrame = CGRect(origin: cropRect.origin.inverse(), size: srcImageSize)
        srcImage.draw(in: dstFrame)

        let dstImage = UIGraphicsGetImageFromCurrentImageContext()
        if dstImage == nil {
            assertionFailure("could not generate dst image.")
        }
        return dstImage
    }
}
