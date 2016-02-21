//
//  ImageContainer.swift
//  picdive
//
//  Created by Sean Ellis on 2/21/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

class ImageContainer : UIView {
    
    var images: [UIImage] = [] {
        didSet {
            self.imageViews.forEach { (imageView: UIImageView) -> () in
                imageView.removeFromSuperview()
            }
            self.imageViews = self.images.map { (image: UIImage) -> UIImageView in
                let imageView = UIImageView()
                imageView.image = image
                imageView.contentMode = UIViewContentMode.ScaleToFill
                self.addSubview(imageView)
                return imageView
            }
        }
    }
    
    private var imageViews: [UIImageView] = []
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSide: CGFloat = fmin(self.height, self.width / self.images.count.f)
        
        self.imageViews.enumerate().forEach { (index: Int, imageView: UIImageView) -> () in
            imageView.size = CGSize(width: imageSide, height: imageSide)
            imageView.frame.origin.x += index.f * imageSide
        }
    }
    
}
