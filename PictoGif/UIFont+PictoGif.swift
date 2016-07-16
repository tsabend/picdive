//
//  UIFont+PicDive.swift
//  picdive
//
//  Created by Sean on 3/6/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

extension UIFont {
    class func PDFont(withSize size: CGFloat) -> UIFont {
        return UIFont(name: "Myriad Pro", size: size)!
    }
    
    class func MemeFont(withSize size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-CondensedBlack", size: size)!
    }
    
    func sizeOf(string string: NSString, constrainedToWidth width: CGFloat) -> CGSize {
        let size = CGSize(width, CGFloat.max)
        return string.boundingRectWithSize(
            size,
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: self],
            context: nil).size
    }
    
}
