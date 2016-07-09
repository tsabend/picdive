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

/// Represents an array of images that can be represented as an animated gif, a video or a photostrip.
class Gif {
    /// The images that make up the gif in the original order
    let images: [UIImage]
    private let times: [Double]
    private let reversed: Bool

    init(images: [UIImage], easing: TimingEasing, totalTime: Double) {
        self.images = images
        self.times = easing.times(framesCount: images.count, totalTime: totalTime)
        self.reversed = easing.reversed
    }
    
    /// The data representation of the gif
    lazy var data: NSData? = {
        let cgImages = self.orderedAndWatermarkedImages.map { $0.CGImage! }
        
        guard let destination = CGImageDestinationCreateWithURL(self.url, kUTTypeGIF, cgImages.count, nil) else { return nil }
        let props = zip(cgImages, self.times)
        props.forEach { (image: CGImage, delay: Double) -> () in
            let timingProperties = [kCGImagePropertyGIFDictionary.s: [kCGImagePropertyGIFDelayTime.s: delay]]
            CGImageDestinationAddImage(destination, image, timingProperties)
        }
        let fileProps = [kCGImagePropertyGIFDictionary.s: [kCGImagePropertyGIFLoopCount.s: 0]]
        CGImageDestinationSetProperties(destination, fileProps)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return NSData(contentsOfURL: self.url)
    }()
    
    /// An image representing the gif.
    lazy var image: UIImage? = {
        guard let data = self.data else { return nil }
        return UIImage.gifWithData(data)
    }()
    
    private lazy var url: NSURL = {
        let documentsDirectory = NSTemporaryDirectory()
        return NSURL(fileURLWithPath: documentsDirectory).URLByAppendingPathComponent("temp.gif")
    }()

    /// The images ordered based on the easing and watermarked if needed
    private lazy var orderedAndWatermarkedImages: [UIImage] = {
        let images = PicDiveProducts.hasPurchasedWatermark ? self.images : self.images.map { $0.watermark() }
        return self.reversed ? images.reverse() : images
    }()
    
    /// The gif as a vertical strip of images
    lazy var verticalStrip: UIImage? = UIImage.stitchImagesVertical(self.orderedAndWatermarkedImages)

    /// This function returns a completion block with the 
    /// url of the video representation. 
    /// - parameter completion: callback from the video conversion. Result can throw.
    func asVideo(completion: (Result<NSURL?>) -> Void) {
        guard let first = self.images.first else { completion(Result { throw VideoWritingError.InvalidImages }); return }
        let settings = RenderSettings(size: first.size)
        
        let imageTimes: [(image: UIImage, time: Double)] = Array(zip(self.orderedAndWatermarkedImages, self.times))
        ImageAnimator(imageTimes: imageTimes, renderSettings: settings)?.render(completion)
    }
    
    lazy var analyticsDictionary: [String : AnyObject] = {
        return [
            "number of frames" : self.images.count,
            "total time" : self.times.reduce(0, combine: +),
            "reversed" : self.reversed ? "yes" : "no"
        ]
    }()
}