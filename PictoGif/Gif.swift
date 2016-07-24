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
    var watermarkedImages: [UIImage]?
    let totalTime: Double
    let easing: TimingEasing
    private let times: [Double]
    private let memeInfo: MemeInfo?
    
    var lastImage: UIImage {
        return self.processedImages.last!
    }
    
    init(images: [UIImage], easing: TimingEasing, totalTime: Double, memeInfo: MemeInfo? = nil, watermarkedImages: [UIImage]? = nil) {
        self.memeInfo = memeInfo
        self.images = images
        self.easing = easing
        self.totalTime = totalTime
        self.watermarkedImages = watermarkedImages
        self.times = easing.times(framesCount: images.count, totalTime: totalTime)
    }
    
    /// The data representation of the gif
    lazy var data: NSData? = {
        let cgImages = self.processedImages.map { $0.CGImage! }
        
        guard let destination = CGImageDestinationCreateWithURL(self.url, kUTTypeGIF, cgImages.count, nil) else { return nil }
        let fileProps = [kCGImagePropertyGIFDictionary.s: [kCGImagePropertyGIFLoopCount.s: 0]]
        CGImageDestinationSetProperties(destination, fileProps)
        
        let props = zip(cgImages, self.times)
        props.forEach { (image: CGImage, delay: Double) -> () in
            let timingProperties = [kCGImagePropertyGIFDictionary.s: [kCGImagePropertyGIFDelayTime.s: delay]]
            CGImageDestinationAddImage(destination, image, timingProperties)
        }
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
    
    lazy var imagesWithWatermarkIfNecessary: [UIImage] = {
        if PicDiveProducts.hasPurchasedWatermark { return self.images }
        
        if let images = self.watermarkedImages {
            return images
        }
        let images = self.images.map { $0.watermark() }
        self.watermarkedImages = images
        return images
    }()

    /// The images ordered based on the easing and watermarked if needed
    private lazy var processedImages: [UIImage] = {
        var images = self.imagesWithWatermarkIfNecessary
        switch self.easing {
        case .Reverse, .ReverseFinalFrame, .ReverseFirstFrame:
            images = images.reverse()
        case .InOut:
            images = images + images.reverse()
        default:
            break
        }
        
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
        do {
            try ImageAnimator(imageTimes: self.videoTimes, renderSettings: self.videoRenderSettings).render(completion)
        } catch let error {
           completion(Result { throw error })
        }
    }
    
    lazy var videoTimes: [ImageTime] = {
        let imageTimes: [ImageTime] = Array(zip(self.processedImages, self.times))
        let repeats = Int(ceil(3 / self.totalTime))
        var videoTimes: [ImageTime] = []
        for _ in 0..<repeats {
            videoTimes += imageTimes
        }
        return videoTimes
    }()
    
    lazy var videoRenderSettings: RenderSettings = RenderSettings(size: self.images.first?.size ?? CGSize.zero, videoFilename: "pictogif", videoExtension: .MP4)
    
    lazy var analyticsDictionary: [String : AnyObject] = {
        return [
            "number of frames" : self.images.count,
            "total time" : self.times.reduce(0, combine: +),
            "reversed" : self.easing.reversed ? "yes" : "no"
        ]
    }()
}