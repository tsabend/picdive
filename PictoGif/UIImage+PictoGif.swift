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
            let image = UIImage(named: "logo_wm")
            let imageRect = CGRect(4, 4, 100, 51)
            image?.drawInRect(imageRect)
        }
    }
    
    func meme(withInfo info: MemeInfo) -> UIImage {
        let horizontalPadding: CGFloat = 10
        let verticalPadding: CGFloat = 8
        return UIImage.drawImage(size: self.size) { (size, context) in
            self.drawInRect(CGRect(origin: CGPoint.zero, size: size))
            let maxTextSize = CGSize(self.size.width - horizontalPadding, CGFloat.max)
            let size = info.topText.boundingRectWithSize(
                maxTextSize,
                options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                attributes:info.topAttributes,
                context: nil).size
            let origin = CGPoint((self.size.width - size.width) / 2, verticalPadding)
            info.topText.drawInRect(CGRect(origin, size), withAttributes: info.topAttributes)
            let bottomSize = info.bottomText.boundingRectWithSize(
                maxTextSize,
                options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                attributes:info.bottomAttributes,
                context: nil).size
            let bottomOrigin = CGPoint((self.size.width - bottomSize.width) / 2, self.size.height - bottomSize.height - verticalPadding)
            info.bottomText.drawInRect(CGRect(bottomOrigin, bottomSize), withAttributes: info.bottomAttributes)
            
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
