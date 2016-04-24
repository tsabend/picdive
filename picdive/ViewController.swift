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

class ViewController: UIViewController {

    let gifButton: UIButton = UIButton()
    let reelButton: UIButton = UIButton()
    let imageView: UIImageView = UIImageView()

    let slider: UISlider = UISlider()
    var numFrames: Int = 1

    var scope: PicScopeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.PDDarkGray()
        
        self.gifButton.setTitle("Gif".uppercaseString, forState: .Normal)
        self.gifButton.setTitleColor(UIColor.PDLightGray(), forState: .Normal)
        self.gifButton.addTarget(self, action: #selector(ViewController.gifWasPressed), forControlEvents: .TouchUpInside)
        self.gifButton.backgroundColor = UIColor.PDTeal()
        self.gifButton.titleLabel?.font = UIFont.boldFont(withSize: 32)

        self.reelButton.setTitle("Reel".uppercaseString, forState: .Normal)
        self.reelButton.setTitleColor(UIColor.PDLightGray(), forState: .Normal)
        self.reelButton.addTarget(self, action: #selector(ViewController.reelWasPressed), forControlEvents: .TouchUpInside)
        self.reelButton.backgroundColor = UIColor.PDBlue()
        self.reelButton.titleLabel?.font = UIFont.boldFont(withSize: 32)
        
        self.scope = PicScopeView()

        self.slider.addTarget(self, action: #selector(ViewController.sliderDidSlide(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.slider.minimumValue = 1
        self.slider.maximumValue = 8
        self.slider.value = 4
        self.slider.minimumTrackTintColor = UIColor.PDBlue()
        self.slider.maximumTrackTintColor = UIColor.PDLightGray()
        self.slider.thumbTintColor = UIColor.whiteColor()
        
        self.modalTransitionStyle = .CoverVertical
       
        self.view.addSubview(self.imageView)
        self.view.addSubview(self.gifButton)
        self.view.addSubview(self.reelButton)
        self.view.addSubview(self.scope)
        self.view.addSubview(self.slider)

    
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
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
    
    private func makeReel() -> UIImage? {
        guard let images = self.snapshotImages() else {return nil}
        return UIImage.stitchImages(images)
    }
    

    func gifWasPressed() {
        let vc = GifViewController()
        vc.gif = self.makeGif()
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func reelWasPressed() {
        let vc = ReelViewController()
        vc.reel = self.makeReel()
        self.presentViewController(vc, animated: true, completion: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let margin = 22.f
        let scrollViewSideLength = self.view.width - margin
        
        self.imageView.size = CGSize(self.view.width, self.view.width)
        
        self.slider.sizeToFit()
        self.slider.width = scrollViewSideLength
        self.slider.moveBelow(siblingView: self.imageView, margin: 10, alignment: .Center)
        
        let buttonSize = CGSize(width: self.view.width / 2, height: 80)
        self.gifButton.size = buttonSize
        self.gifButton.alignBottom(0, toView: self.view)
        
        self.reelButton.size = buttonSize
        self.reelButton.moveRight(siblingView: self.gifButton, margin: 0, alignVertically: true)
        
        self.scope.frame = self.imageView.frame
        if self.scope.innerRect == CGRect.zero {
            self.scope.innerRect = CGRect(150, 150, 100, 100)
        }
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}
