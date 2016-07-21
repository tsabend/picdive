//
//  MemeInfo.swift
//  PictoGif
//
//  Created by Thomas Abend on 7/20/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

struct MemeInfo {
    let topText: NSString
    let topFontSize: CGFloat
    let bottomText: NSString
    let bottomFontSize: CGFloat
    let overAll: Bool
    
    var topAttributes: [String : AnyObject] {
        return self.memeAttributes(withSize: self.topFontSize)
    }
    
    var bottomAttributes: [String : AnyObject] {
        return self.memeAttributes(withSize: self.bottomFontSize)
    }
    
    private func memeAttributes(withSize size: CGFloat) -> [String : AnyObject] {
        let textFont: UIFont = UIFont.MemeFont(withSize: size)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center
        return [
            NSFontAttributeName: textFont,
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSStrokeWidthAttributeName: -3.0,
            NSParagraphStyleAttributeName: paragraphStyle
        ]
    }
    
    
}
