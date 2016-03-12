//
//  CropSquareView.swift
//  picdive
//
//  Created by Sean Ellis on 2/21/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit
import CGRectExtensions

class CropSquareView: UIView {
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.backgroundColor = UIColor.clearColor()
        self.layer.borderColor = UIColor.PDRed().CGColor
        self.layer.borderWidth = 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is a complete waste of my time")
    }
    
    var rects: [CGRect] {
        return (0..<self.numberOfBoxes).map { (i: Int) -> CGRect in
            let boxSize = self.frame.size * (1 - self.boxRatio *  i.f)
            return self.frame.center(boxSize)
        }
    }
    
    let boxRatio: CGFloat = 0.2
    var numberOfBoxes = 1
}
//    func drawSquare(rect:CGRect, color: UIColor = UIColor.blackColor()) {
//        let path = UIBezierPath(rect: rect)
//
//        path.lineWidth = 4
//        color.setStroke()
//        path.stroke()
//    }
//
//    override func drawRect(rect: CGRect) {
//        super.drawRect(rect)
//
//        self.rects.enumerate().forEach { (index: Int, rect: CGRect) in
//            if index == self.rects.count - 1 {
//                self.drawSquare(rect, color: UIColor.PDRed())
//            } else {
//                self.drawSquare(rect)
//            }
//        }
//
//    }

//
//
//
//    
//}
