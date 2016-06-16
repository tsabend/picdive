//
//  ZoomingImageView.swift
//  PictoGif
//
//  Created by Thomas Abend on 6/16/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

class ZoomingImageView: UIView, UIScrollViewDelegate {
    var image: UIImage? {
        didSet {
            self.imageView.image = self.image
        }
    }
    
    private let imageView = UIImageView()
    private let scrollView = UIScrollView()
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        self.layer.borderColor = UIColor.PDLightGray().CGColor
        self.layer.borderWidth = 2
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.imageView)
        self.scrollView.maximumZoomScale = 100
        self.scrollView.delegate = self
        self.scrollView.userInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func zoom(toRect rect: CGRect) {
        self.scrollView.zoomToRect(rect, animated: false)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.scrollView.frame = self.bounds
        self.imageView.frame = self.scrollView.bounds
    }
}