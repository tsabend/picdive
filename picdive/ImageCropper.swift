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
        self.scrollView.frame = self.bounds
        self.scrollView.contentSize = image.size
        

    }
    
    func setup() {
        let minScale: CGFloat = 1
        let contentSize = self.scrollView.contentSize
        let scaleWidth = self.scrollView.width / contentSize.width
        let scaleHeight = self.scrollView.height / contentSize.height
        let tmpMinScale = max(scaleWidth, scaleHeight)
        
        self.scrollView.minimumZoomScale = tmpMinScale
        self.scrollView.maximumZoomScale = (tmpMinScale > minScale) ? tmpMinScale : minScale
        self.scrollView.zoomScale = tmpMinScale
        
        self.scrollView.contentOffset.x = (contentSize.width - self.scrollView.width) / 2
        self.scrollView.contentOffset.y = (contentSize.height - self.scrollView.height) / 2
        
    }

    func crop() -> UIImage {
        return UIImage.drawImage(size: self.scrollView.size) { (size, context) in
            CGContextTranslateCTM(context, -self.scrollView.contentOffset.x, -self.scrollView.contentOffset.y)
            self.scrollView.layer.renderInContext(context)
        }
    }
    
}
