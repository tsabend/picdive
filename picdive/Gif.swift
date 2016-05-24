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
    let images: [UIImage]
    
    init?(images: [UIImage], easing: TimingEasing, totalTime: Double) {
        self.init(images: images, times: easing.times(framesCount: images.count, totalTime: totalTime))
    }
    
    init?(images: [UIImage], times: [Double]) {
        guard times.count == images.count else { return nil }
        let fileProps = [kCGImagePropertyGIFDictionary.s: [kCGImagePropertyGIFLoopCount.s: 0]]
        let documentsDirectory = NSTemporaryDirectory()
        let url = NSURL(fileURLWithPath: documentsDirectory).URLByAppendingPathComponent("temp.gif")
        
        guard let destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, images.count, nil) else { return nil }
        CGImageDestinationSetProperties(destination, fileProps)
        
        
        let props = zip(images, times)
        props.forEach { (image: UIImage, delay: Double) -> () in
            let timingProperties = [kCGImagePropertyGIFDictionary.s: [kCGImagePropertyGIFDelayTime.s: delay]]
            let cgImage = image.CGImage!
            CGImageDestinationAddImage(destination, cgImage, timingProperties)
        }
        guard CGImageDestinationFinalize(destination) else { return nil }
        self.url = url
        guard let data = NSData(contentsOfURL: url) else { return nil }
        self.data = data
        guard let image = UIImage.gifWithData(data) else { return nil }
        self.image = image
        self.images = images
    }
}
