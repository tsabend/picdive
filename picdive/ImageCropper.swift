//
//  ImageCropper.swift
//  picdive
//
//  Created by Thomas Abend on 4/23/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

class ImageCropper: UIView, UIScrollViewDelegate {
    
    var image: UIImage? {
        didSet {
            self.imageView.image = image
            self.imageView.frame = CGRect.zero
            self.setNeedsLayout()
        }
    }

    private let imageView = UIImageView()
    private let scrollView = UIScrollView()
    init() {
        super.init(frame: CGRect.zero)
        
        self.scrollView.delegate = self
        
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false

        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.imageView)
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
    
}
