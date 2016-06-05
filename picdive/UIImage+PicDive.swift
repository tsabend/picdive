//
//  UIImage+PicDive.swift
//  picdive
//
//  Created by Thomas Abend on 2/20/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

extension UIImage {
    
    func resized(toSize size: CGSize) -> UIImage {
        return UIImage.drawImage(size: size) { (size: CGSize, context: CGContext) -> () in
            self.drawInRect(CGRect(origin: CGPoint.zero, size: size))
        }
    }
    
    func cropped(inRect rect: CGRect) -> UIImage {
        return UIImage.drawImage(size: rect.size) { (size: CGSize, context: CGContext) -> () in
            let drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, self.size.width, self.size.height)
            CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height))
            self.drawInRect(drawRect)
        }
    }
    
    func watermark() -> UIImage {
        return UIImage.drawImage(size: self.size) { (size, context) in
            self.drawInRect(CGRect(origin: CGPoint.zero, size: size))
            let image = UIImage(named: "PicDive_Logo")
            let imageRect = CGRect(20, 20, 108, 40)
            image?.drawInRect(imageRect)
        }
    }
   

    static func drawImage(size size: CGSize!, closure: (size: CGSize, context: CGContext) -> Void) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.mainScreen().scale)
        closure(size: size, context: UIGraphicsGetCurrentContext()!)
        let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    

    private static func accumulateSize(size: CGSize, image: UIImage) -> CGSize {
        var size = size
        size.width = max(image.size.width, size.width)
        size.height = max(image.size.height, size.height)
        return size
    }
    
    private static func maxSize(forImages images: [UIImage]) -> CGSize {
        return images.reduce(CGSize.zero, combine: UIImage.accumulateSize)
    }
    
    static func stitchImagesVertical(images: [UIImage]) -> UIImage? {
        let maxSize = UIImage.maxSize(forImages: images)
        let totalSize = CGSize(width: maxSize.width, height: maxSize.height * images.count.f)
        return UIImage.drawImage(size: totalSize) { (size, context) -> Void in
            images.enumerate().forEach { (index: Int, image: UIImage) -> () in
                let rect = CGRect(origin: CGPoint(0, maxSize.height * index.f), size: maxSize)
                image.drawInRect(rect)
            }

        }
    }
    
    static func stitchImagesHorizontal(images: [UIImage]) -> UIImage? {
        let maxSize = UIImage.maxSize(forImages: images)
        let totalSize = CGSize(width: maxSize.width  * images.count.f, height: maxSize.height)
        return UIImage.drawImage(size: totalSize) { (size, context) -> Void in
            images.enumerate().forEach { (index: Int, image: UIImage) -> () in
                let rect = CGRect(origin: CGPoint(maxSize.width * index.f, 0), size: maxSize)
                image.drawInRect(rect)
            }
            
        }
    }
}
