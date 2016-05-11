//
//  ViewController.swift
//  picdive
//
//  Created by Sean on 2/17/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit
import SwiftGifOrigin
import CGRectExtensions
import pop

public func after(seconds seconds: Double, exec: ()->Void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * 1e9)), dispatch_get_main_queue(), exec)
}

class ScopeViewController: UIViewController, ImagePresenter, FlowViewController {

    typealias Next = CustomizeGifViewController
    var imageViewDataSource: ImageViewDataSource? {
        didSet {
            if let image = self.imageViewDataSource as? UIImage {
                self.imageView.image = image
            }
        }
    }
    
    var nextImageViewDataSource: ImageViewDataSource? {
        return self.makeGif()
    }
    
    
    private let imageView: UIImageView = UIImageView()

    let slider: UISlider = UISlider()
    var numFrames: Int = 1

    var scope: PicScopeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Enhance!"
        self.setupNavigationBar()
        
        self.view.backgroundColor = UIColor.PDDarkGray()
        
        self.scope = PicScopeView()

        self.slider.addTarget(self, action: #selector(ScopeViewController.sliderDidSlide(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.slider.minimumValue = 2
        self.slider.maximumValue = 7
        self.slider.value = 4
        self.slider.minimumTrackTintColor = UIColor.PDBlue()
        self.slider.maximumTrackTintColor = UIColor.PDLightGray()
        self.slider.thumbTintColor = UIColor.whiteColor()
        
        self.modalTransitionStyle = .CoverVertical
       
        self.view.addSubview(self.imageView)
        self.view.addSubview(self.scope)
        self.view.addSubview(self.slider)
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let offscreen = self.view.height + self.slider.height
        self.slider.y = offscreen
        
        after(seconds: 0.1) {
            let originalPos = self.imageView.maxY + 28
            
            
            let anim = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            anim.toValue = originalPos
            anim.velocity = 4
            anim.springBounciness = 4
            anim.springSpeed = 4
            self.slider.layer.pop_addAnimation(anim, forKey: "slider")
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        UIView.animateWithDuration(0.33, animations: {
            self.slider.y = self.view.height + self.slider.height
            }, completion: nil)
        super.viewWillDisappear(animated)
    }

    
    func sliderDidSlide(slider: UISlider) {
        let roundedValue = round(slider.value)
        slider.setValue(roundedValue, animated: false)
        self.scope.numberOfSteps = Int(roundedValue)
    }
    
    private func snapshotImages() -> [UIImage]? {
        guard let image = self.imageView.image else { return nil }
        
        return self.scope.frames.map { (rect: CGRect) -> UIImage in
            return image
                .cropped(inRect: rect)
                .resized(toSize: self.imageView.size)
        }
    }
    
    private func makeGif() -> Gif? {
        let time = Double(4 / self.slider.value)
        if let images = self.snapshotImages() {
            return Gif(images: images, delay: time)
        }
        return nil
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let margin = 22.f
        let scrollViewSideLength = self.view.width - margin
        
        self.imageView.size = CGSize(self.view.width, self.view.width)
        self.imageView.center = self.view.center
        
        self.slider.sizeToFit()
        self.slider.width = scrollViewSideLength
        self.slider.centerHorizontally(self.imageView)
        
        
        self.scope.frame = self.imageView.frame
        
        if self.scope.innerRect == CGRect.zero {
            self.scope.innerRect = CGRect(150, 150, 100, 100)
        }
        
    }
}
