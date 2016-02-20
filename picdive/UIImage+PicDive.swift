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
   
    static func drawImage(size size: CGSize!, closure: (size: CGSize, context: CGContext) -> ()) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.mainScreen().scale)
        closure(size: size, context: UIGraphicsGetCurrentContext()!)
        let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
