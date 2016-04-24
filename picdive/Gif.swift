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
    let url: NSURL
    let data: NSData
    let image: UIImage
    
    init?(images: [UIImage], delay: Double) {
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
        guard CGImageDestinationFinalize(destination) else { return nil }
        self.url = url
        guard let data = NSData(contentsOfURL: url) else { return nil }
        self.data = data
        guard let image = UIImage.gifWithData(data) else { return nil }
        self.image = image
    }
}
