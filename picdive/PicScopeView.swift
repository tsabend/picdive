//
//  CropSquareView.swift
//  picdive
//
//  Created by Sean Ellis on 2/21/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit
import CGRectExtensions


class BoxView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.5).CGColor
        self.layer.borderWidth = 2
        self.userInteractionEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PicScopeView: UIView {
    
    var numberOfSteps = 4 {
        didSet {
            self.resetBoxes()
        }
    }
    
    private var boxes: [UIView] = []
    var innerRect: CGRect {
        get {
            return self.innerBox.frame
        }
        set {
            self.innerBox.frame = newValue
            self.resetBoxes()
        }
    }
    
    private let innerBox = BoxView(frame: CGRect.zero)
    var frames: [CGRect] {
        let boxes = self.boxes + [self.innerBox]
        return boxes.map{$0.frame}
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupBoxGestures()
        self.addSubview(self.innerBox)
    }
    
    private func setupBoxGestures() {
        self.innerBox.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.4)
        self.innerBox.userInteractionEnabled = true
    
        let pan = UIPanGestureRecognizer(target: self, action: #selector(PicScopeView.boxWasMoved))
        self.innerBox.addGestureRecognizer(pan)
    
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(PicScopeView.boxWasPinched))
        self.addGestureRecognizer(pinch)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func resetBoxes() {
        self.boxes.forEach {$0.removeFromSuperview() }
        self.boxes = self.buildRects().map { BoxView(frame: $0) }
        self.setupBoxGestures()
        self.boxes.forEach(self.addSubview)
    }
    
    private func buildRects() -> [CGRect] {

        let innerSideLength = self.innerRect.width
        let percentage = innerSideLength / self.width
        
        return Array(0...self.numberOfSteps - 1).map { (i: Int) -> CGRect in
            let scale = 1 - ((1 - percentage) / self.numberOfSteps.f * i.f)
            let scaledSideLength = self.width * scale

            let originShift = i.f / self.numberOfSteps.f
            let x = self.innerRect.x * originShift
            let y = self.innerRect.y * originShift
            return CGRect(x: x, y: y, width: scaledSideLength, height: scaledSideLength)
        }
    }
    
    func boxWasMoved(pan: UIPanGestureRecognizer) {
        guard let view = pan.view else { return }

        if pan.state == .Began {
            self.boxes.forEach {$0.removeFromSuperview() }
        }
        if pan.state == .Changed {
            
            let viewSize = view.size
            let translation = pan.translationInView(self)
            var center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
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
            view.center = center
            pan.setTranslation(CGPoint.zero, inView: self)
            
        }
        if pan.state == .Ended {
            
            self.innerRect = view.frame
        }
    }
    
    
    func boxWasPinched(pinch: UIPinchGestureRecognizer) {
        let view = self.innerBox
        if pinch.state == .Began {
            self.boxes.forEach {$0.removeFromSuperview() }
        }
        let newSideLength = view.width * pinch.scale

        if view.origin.x + newSideLength < self.width && view.origin.y + newSideLength < self.height {
            let center = view.center
            view.size = CGSize(width: newSideLength, height: newSideLength)
            view.center = center
        }
        pinch.scale = 1
        if pinch.state == .Ended {
            self.resetBoxes()
        }
        
    }

}