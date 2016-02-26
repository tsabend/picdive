//
//  Gif.swift
//  picdive
//
//  Created by Sean on 2/25/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit
import ImageIO
import MobileCoreServices

extension CFString {
    var s: String {
        return String(self)
    }
}

struct Gif {
    static func makeFile(images: [UIImage], delay: Double) -> NSURL? {
        let fileProps = [kCGImagePropertyGIFDictionary.s: [kCGImagePropertyGIFLoopCount.s: 0]]
        let frameProperties = [kCGImagePropertyGIFDictionary.s: [kCGImagePropertyGIFDelayTime.s: delay]]
        let documentsDirectory = NSTemporaryDirectory()
        let url = NSURL(fileURLWithPath: documentsDirectory).URLByAppendingPathComponent("temp.gif")
        
        guard let destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, images.count, nil) else { return nil }
        CGImageDestinationSetProperties(destination, fileProps)
        
        images.forEach { (image: UIImage) -> () in
            let cgImage = image.CGImage!
            CGImageDestinationAddImage(destination, cgImage, frameProperties)
        }
        return CGImageDestinationFinalize(destination) ? url : nil
    }
    
    static func makeData(images: [UIImage], delay: Double) -> NSData? {
        if let url = Gif.makeFile(images, delay: delay) {
            return NSData(contentsOfURL: url)
        }
        return nil
    }
}
