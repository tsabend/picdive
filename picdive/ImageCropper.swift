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
        self.scrollView.maximumZoomScale = 4
        
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
        self.scrollView.frame = self.bounds
        
        guard let image = image else { return }
        let aspectRatio = image.size.height/image.size.width
        self.imageView.width = self.scrollView.width
        self.imageView.height = self.scrollView.height * aspectRatio
    }

    func crop() -> UIImage {
        return UIImage.drawImage(size: self.scrollView.size) { (size, context) in
            CGContextTranslateCTM(context, -self.scrollView.contentOffset.x, -self.scrollView.contentOffset.y)
            self.scrollView.layer.renderInContext(context)
        }
    }
    
}
