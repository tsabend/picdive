//
//  ImageCropper.swift
//  picdive
//
//  Created by Thomas Abend on 4/23/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

class ImageCropper: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    var image: UIImage? {
        didSet {
            self.imageView.image = image
            self.imageView.frame = CGRect.zero
            self.setNeedsLayout()
        }
    }

    private let imageView = UIImageView()
    private let scrollView = UIScrollView()
    private let gridOverlay = GridOverlay()

    init() {
        super.init(frame: CGRect.zero)
        
        self.clipsToBounds = true
        
        self.scrollView.delegate = self
        
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false

        self.imageView.userInteractionEnabled = true

        self.longPress.delegate = self
        self.imageView.addGestureRecognizer(self.longPress)
        
        self.addSubview(self.scrollView)
        self.addSubview(self.gridOverlay)

        self.scrollView.addSubview(self.imageView)
    }
    lazy var longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ImageCropper.handleLongPress))
    
    // MARK: - gestures
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer == self.longPress
    }
    
    var panGestureRecognizer: UIPanGestureRecognizer {
        return self.scrollView.panGestureRecognizer
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not in this app")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let image = image else { return }
        self.gridOverlay.frame = self.bounds

        self.imageView.sizeToFit()
        self.imageView.origin = CGPoint.zero
        self.scrollView.frame = self.bounds
        self.scrollView.contentSize = image.size
        
        let scaleWidth = self.scrollView.width / image.size.width
        let scaleHeight = self.scrollView.height / image.size.height
        let scale = max(scaleWidth, scaleHeight)
        
        self.scrollView.minimumZoomScale = scale
        self.scrollView.maximumZoomScale = max(scale, 4) // always allow at least 4x zoom
        self.scrollView.zoomScale = scale
        
        self.scrollView.contentInset = UIEdgeInsetsZero

        self.scrollView.contentOffset.x = (self.scrollView.contentSize.width - self.scrollView.width) / 2
        self.scrollView.contentOffset.y = (self.scrollView.contentSize.height - self.scrollView.height) / 2
    }

    func crop() -> UIImage? {
        guard self.image != nil else { return nil }
        return UIImage.drawImage(size: self.scrollView.size) { (size, context) in
            CGContextTranslateCTM(context, -self.scrollView.contentOffset.x, -self.scrollView.contentOffset.y)
            self.scrollView.layer.renderInContext(context)
        }
    }
    
    func handleLongPress(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .Began {
            self.gridOverlay.fadeIn()
        } else if gestureRecognizer.state == .Ended {
            self.gridOverlay.fadeOut()
        }
    }
    
    func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView?) {
        self.gridOverlay.fadeIn()
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        self.gridOverlay.fadeOut()
    }
    
    // MARK: - scrolling
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.gridOverlay.fadeIn()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.gridOverlay.fadeOut()
    }
    
    class GridOverlay : UIView {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.alpha = 0
            self.backgroundColor = UIColor.clearColor()
            self.userInteractionEnabled = false
            self.layer.borderColor = UIColor.PDLightGray().CGColor
            self.layer.borderWidth = 2
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func fadeIn() {
            UIView.animateWithDuration(0.2) {
                self.alpha = 1
            }
        }
        
        func fadeOut() {
            UIView.animateWithDuration(0.2) {
                self.alpha = 0
            }
        }
        
        override func drawRect(rect: CGRect) {
            super.drawRect(rect)
            let context = UIGraphicsGetCurrentContext()
            CGContextBeginPath(context)
            
            for idx in 1...2 {
                let linePos = self.bounds.width * CGFloat(idx) / 3.0
                CGContextMoveToPoint(context, linePos, 0)
                CGContextAddLineToPoint(context, linePos, self.bounds.height)
            }
            
            for idx in 1...2 {
                let linePos = self.bounds.height * CGFloat(idx) / 3.0
                CGContextMoveToPoint(context, 0, linePos)
                CGContextAddLineToPoint(context, self.bounds.width, linePos)
            }
            
            UIColor.PDLightGray().setStroke()
            CGContextStrokePath(context)
            UIGraphicsPopContext()
        }
    }
    
}
