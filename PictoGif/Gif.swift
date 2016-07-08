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
    let times: [Double]
    let reversed: Bool
    
    init?(images: [UIImage], easing: TimingEasing, totalTime: Double) {
        self.images = images
        let images = PicDiveProducts.hasPurchasedWatermark ? images : images.map { $0.watermark() }
        
        let times = easing.times(framesCount: images.count, totalTime: totalTime)
        

        guard times.count == images.count else { return nil }
        let fileProps = [kCGImagePropertyGIFDictionary.s: [kCGImagePropertyGIFLoopCount.s: 0]]
        let documentsDirectory = NSTemporaryDirectory()
        let url = NSURL(fileURLWithPath: documentsDirectory).URLByAppendingPathComponent("temp.gif")
        
        guard let destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, images.count, nil) else { return nil }
        CGImageDestinationSetProperties(destination, fileProps)
        
        // Reverse the images used to make the gif, but save the images in the original order
        let imagesForGif = easing.reversed ? images.reverse() : images
        let props = zip(imagesForGif, times)
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
        self.times = times
        self.reversed = easing.reversed
    }
    
    var orderedAndWatermarkedImages: [UIImage] {
        let images = PicDiveProducts.hasPurchasedWatermark ? self.images : self.images.map { $0.watermark() }
        return self.reversed ? images.reverse() : images
    }
    
    var verticalStrip: UIImage? {
        return UIImage.stitchImagesVertical(self.orderedAndWatermarkedImages)
    }
    
    func asVideo(completion: (Result<NSURL?>)-> Void) {
        guard let first = self.images.first else { completion(Result { throw VideoWritingError.InvalidImages }); return }
        let settings = RenderSettings(size: first.size)
        
        let imageTimes: [(image: UIImage, time: Double)] = Array(zip(self.orderedAndWatermarkedImages, self.times))
        ImageAnimator(imageTimes: imageTimes, renderSettings: settings)?.render(completion)
    }
}
