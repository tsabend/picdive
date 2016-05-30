//
//  CropSquareView.swift
//  picdive
//
//  Created by Sean Ellis on 2/21/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit
import CGRectExtensions

class PicScopeView: UIView {
    /// The number of frames to generate between the outer and inner box
    var numberOfSteps = 4 { didSet { self.resetBoxes() } }
    
    /// The frames of all of the boxes
    var frames: [CGRect] { return self.boxes.map{$0.frame} }
    
    /// The frame of the inner box. Setting this value
    /// will regenerate the boxes
    var innerRect: CGRect = CGRect.zero {
        didSet {
            self.resetBoxes()
        }
    }
    
    private var boxes: [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(PicScopeView.boxWasMoved))
        self.addGestureRecognizer(pan)
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(PicScopeView.boxWasPinched))
        self.addGestureRecognizer(pinch)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Boxes
    private func resetBoxes() {
        self.boxes.forEach {$0.removeFromSuperview() }
        self.boxes = self.buildRects().map { BoxView(frame: $0) }
        self.boxes.last?.backgroundColor = UIColor.PDLightGray().colorWithAlphaComponent(0.33)
        self.boxes.forEach(self.addSubview)
    }
    
    private func buildRects() -> [CGRect] {
        return self
            .frame
            .squaresBetween(rect: self.innerRect, steps: self.numberOfSteps)
    }
    
    // MARK: - Gestures
    func boxWasMoved(pan: UIPanGestureRecognizer) {
        let innerRect = self.innerRect

        if pan.state == .Changed {
            
            let viewSize = innerRect.size
            let translation = pan.translationInView(self)
            var center = CGPoint(x: innerRect.center.x + translation.x, y: innerRect.center.y + translation.y)
            var resetTranslation = CGPoint(x: translation.x, y: translation.y)
            if center.x - viewSize.width / 2 < 0 {
                center.x = viewSize.width / 2
            } else if center.x + viewSize.width / 2 > self.width{
                center.x = self.width - viewSize.width / 2
            } else {
                resetTranslation.x = 0
            }
            
            if center.y - viewSize.height / 2 < 0 {
                center.y = viewSize.height / 2
            } else if center.y + viewSize.height / 2 > self.height {
                center.y = self.height - viewSize.height / 2
            } else {
                resetTranslation.y = 0
            }
            self.innerRect.center = center
            pan.setTranslation(CGPoint.zero, inView: self)
            self.resetBoxes()
        }
    }
    
    
    func boxWasPinched(pinch: UIPinchGestureRecognizer) {
        self.boxWasScaled(pinch.scale)
        print(pinch.scale)
        pinch.scale = 1

        
    }
    
    private func boxWasScaled(scale: CGFloat) {
        let innerRect = self.innerRect
        let newSideLength = innerRect.width * scale
        
        if innerRect.origin.x + newSideLength < self.width && innerRect.origin.y + newSideLength < self.height {
            let center = innerRect.center
            self.innerRect.size = CGSize(width: newSideLength, height: newSideLength)
            self.innerRect.center = center
        }
    }
    
    func animate() {
        let total = 400
        (0...total).forEach { (idx) in
            let scale: CGFloat = idx >= total/2 ? 1.005 : 0.995
            after(seconds: 0.00125 * idx.d, exec: {
                self.boxWasScaled(scale)
            })
          
        }
    }

    // MARK: - BoxView
    class BoxView: UIView {
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.5).CGColor
            self.layer.borderWidth = 2
        }
        
        required init?(coder aDecoder: NSCoder) { fatalError("") }
    }
    
    enum Easing {
        case In, Out, Linear
    }
}