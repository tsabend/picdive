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
    let totalTime: Double
    let easing: TimingEasing
    private let times: [Double]
    private let reversed: Bool
    private let memeInfo: MemeInfo?
    
    init(images: [UIImage], easing: TimingEasing, totalTime: Double, memeInfo: MemeInfo? = nil) {
        self.memeInfo = memeInfo
        self.images = images
        self.easing = easing
        self.totalTime = totalTime
        self.times = easing.times(framesCount: images.count, totalTime: totalTime)
        self.reversed = easing.reversed
    }
    
    /// The data representation of the gif
    lazy var data: NSData? = {
        let cgImages = self.processedImages.map { $0.CGImage! }
        
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
    private lazy var processedImages: [UIImage] = {
        var images = self.reversed ? self.images.reverse() : self.images
        
        images = PicDiveProducts.hasPurchasedWatermark ? images : images.map { $0.watermark() }
        if let memeInfo = self.memeInfo {
            if memeInfo.overAll {
                images = images.map(self.meme)
            } else {
                let memed = self.meme(images.last!)
                images = images.dropLast() + [memed]
            }
        }
        return images
    }()
    
    private func meme(image: UIImage) -> UIImage {
        guard let info = self.memeInfo else { return image }
        return image.meme(withInfo: info)
    }
    
    
    
    /// The gif as a vertical strip of images
    lazy var verticalStrip: UIImage? = UIImage.stitchImagesVertical(self.processedImages)

    /// This function returns a completion block with the 
    /// url of the video representation. 
    /// - parameter completion: callback from the video conversion. Result can throw.
    func asVideo(completion: (Result<NSURL>) -> Void) {
        let settings = RenderSettings(size: self.images.first?.size ?? CGSize.zero, videoFilename: "pictogif", videoExtension: .MP4)
        let imageTimes: [ImageTime] = Array(zip(self.processedImages, self.times))
        do {
            try ImageAnimator(imageTimes: imageTimes, renderSettings: settings).render(completion)
        } catch let error {
           completion(Result { throw error })
        }
    }
    
    lazy var analyticsDictionary: [String : AnyObject] = {
        return [
            "number of frames" : self.images.count,
            "total time" : self.times.reduce(0, combine: +),
            "reversed" : self.reversed ? "yes" : "no"
        ]
    }()
}