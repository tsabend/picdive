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
    var numberOfBoxes = 1
    let boxRatio: CGFloat = 0.2
    

    override init(frame: CGRect) {
        super.init(frame:frame)
        self.backgroundColor = UIColor.clearColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is a complete waste of my time")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        
    }
    
    func drawSquare(rect:CGRect) {
        let path = UIBezierPath(rect: rect)
        
        path.lineWidth = 4
        UIColor.blackColor().setStroke()
        path.stroke()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        self.rects.forEach { (rect: CGRect) -> () in
            self.drawSquare(rect)
        }
        
    }
    
    var rects: [CGRect] {
        return (0..<self.numberOfBoxes).map { (i: Int) -> CGRect in
           let boxSize = self.frame.size * (1 - self.boxRatio *  i.f)
           return self.frame.center(boxSize)
        }
    }
    

    
}
