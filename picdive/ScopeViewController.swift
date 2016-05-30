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

    let slider: Slider = Slider()
    var numFrames: Int = 1

    var scope: PicScopeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Enhance!"
        self.setupNavigationBar()
        
        self.view.backgroundColor = UIColor.PDDarkGray()
        
        self.scope = PicScopeView()

        self.slider.addTarget(self, action: #selector(ScopeViewController.sliderDidSlide(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.slider.setupValues(min: 2, max: 7, initial: 4)
        self.slider.setupImages(min: UIImage(named: "few-frames"), max: UIImage(named: "many-frames"))
        
        self.modalTransitionStyle = .CoverVertical
        
        self.view.addSubview(self.imageView)
        self.view.addSubview(self.scope)
        self.view.addSubview(self.slider)
    
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
    }
    
    func animateIn() {
        
        let offscreen = self.view.height + self.slider.height
        self.slider.y = offscreen
        after(seconds: 0.01) {
            let originalPos = self.imageView.maxY + 64
            
            
            let anim2 = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            anim2.toValue = originalPos
            anim2.velocity = 8
            anim2.springBounciness = 4
            anim2.springSpeed = 4
            self.slider.layer.pop_addAnimation(anim2, forKey: "slider")
            self.scope.animate()
        }
    }
    
    func back() {
        UIView.animateWithDuration(0.2, animations: {
            let offscreen = self.view.height + self.slider.height
            let sliderAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            sliderAnimation.toValue = offscreen
            sliderAnimation.velocity = 4
            sliderAnimation.springBounciness = 4
            sliderAnimation.springSpeed = 4
            self.slider.layer.pop_addAnimation(sliderAnimation, forKey: "slider")
            }, completion: { _ in
                self.navigationController?.popViewControllerAnimated(false)
        })
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
        if let images = self.snapshotImages() {
            return Gif(images: images, easing: TimingEasing.Linear, totalTime: Double(self.slider.value))
        }
        return nil
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let margin = 22.f
        let scrollViewSideLength = self.view.width - margin
        
        self.imageView.size = CGSize(self.view.width, self.view.width)
        self.imageView.y = self.navigationController?.navigationBar.maxY ?? 0
        
        self.slider.sizeToFit()
        self.slider.width = scrollViewSideLength
        self.slider.centerHorizontally(self.imageView)
        
        
        self.scope.frame = self.imageView.frame
        
        if self.scope.innerRect == CGRect.zero {
            self.scope.innerRect = CGRect(150, 150, 100, 100)
        }
        
    }
}
