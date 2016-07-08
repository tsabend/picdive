//
//  ImageAnimator.swift
//  PictoGif
//
//  Created by Thomas Abend on 6/10/16.
//  Copyright © 2016 Sean. All rights reserved.
//

// modified from http://stackoverflow.com/questions/3741323/how-do-i-export-uiimage-array-as-a-movie
import AVFoundation
import UIKit
import Photos

    class ImageAnimator {
    
    // Apple suggests a timescale of 600 because it's a multiple of standard video rates 24, 25, 30, 60 fps etc.
    static let kTimescale: Double = 600
    
    let settings: RenderSettings
    let videoWriter: VideoWriter
    let imageTimes: [(image: UIImage, time: Double)]
    
    class func removeFileAtURL(fileURL: NSURL) {
        do { try NSFileManager.defaultManager().removeItemAtPath(fileURL.path!) } catch {}
    }
    
    init?(imageTimes: [(image: UIImage, time: Double)], renderSettings: RenderSettings) {
        guard imageTimes.count > 0 else { return nil }
        self.settings = renderSettings
        self.videoWriter = VideoWriter(renderSettings: settings)
        self.imageTimes = imageTimes
    }
    
    func render(completion: (Result<NSURL?>) -> Void) {
        
        // The VideoWriter will fail if a file exists at the URL, so clear it out first.
        ImageAnimator.removeFileAtURL(self.settings.outputURL)
            
        self.videoWriter.start()
        let totalDuration = self.imageTimes.map{$0.time}.reduce(0, combine: +)
        self.videoWriter.render(self.appendPixelBuffers, totalDuration: totalDuration) { (result: Result<Void>) in
            do {
                try result.unwrap()
                completion(Result { _ in self.settings.outputURL })
            } catch let error {
                completion(Result { throw error})
            }
        }
    }

    // This is the callback function for VideoWriter.render()
    func appendPixelBuffers(writer: VideoWriter) throws -> Bool {
        
        var elapsed: CMTime = CMTimeMake(0, Int32(ImageAnimator.kTimescale))

        for imageTime in self.imageTimes {
            if writer.isReadyForData == false {
                // Inform writer we have more buffers to write.
                return false
            }

            let frameDuration = CMTimeMake(Int64(ImageAnimator.kTimescale * imageTime.time), Int32(ImageAnimator.kTimescale))
            try writer.addImage(imageTime.image, withPresentationTime: elapsed)
            elapsed = CMTimeAdd(elapsed, frameDuration)

        }
        
        try writer.addImage(self.imageTimes.last!.image, withPresentationTime: elapsed)
        // Inform writer all buffers have been written.
        return true
    }
        
}