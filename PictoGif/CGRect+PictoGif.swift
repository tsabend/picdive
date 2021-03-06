//
//  CGRect+PicDive.swift
//  picdive
//
//  Created by Thomas Abend on 5/1/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit
func >(lhs: CGSize, rhs: CGSize) -> Bool {
    return lhs.height > rhs.height && lhs.width > rhs.width
}


public extension CGRect {
    
    public var square: Bool { return self.width == self.height }

    func squaresBetween(rect otherRect: CGRect, steps: Int) -> [CGRect] {
        guard self.size > otherRect.size else { return [] }
        guard self.square && otherRect.square else { return [] }

        let between = steps - 1
        return Array(0...between).map { (i: Int) -> CGRect in
            let scale = 1 - ((1 - otherRect.width / self.width) / between.f * i.f)
            let scaledSideLength = self.width * scale
            
            let originShift = i.f / between.f
            let x = otherRect.x * originShift
            let y = otherRect.y * originShift
            return CGRect(x: x, y: y, width: scaledSideLength, height: scaledSideLength)
        }

    }
    
    
    func horizontallyCenteredRectForString(string: NSString, withAttributes attributes: [String:AnyObject]) -> CGRect {
        let size = string.sizeWithAttributes(attributes)
        return CGRectMake(self.origin.x + (self.size.width-size.width)/2.0 , self.origin.y, self.size.width, size.height)
    }
    
}
