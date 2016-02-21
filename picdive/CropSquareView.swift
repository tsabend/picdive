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
        
        for i in (0..<self.numberOfBoxes) {
            let boxSize = rect.size * (1 - self.boxRatio *  i.f)
            let resizedRect = rect.center(boxSize)
            self.drawSquare(resizedRect)
        }
    }
    

    

    
}
