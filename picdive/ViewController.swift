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

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let button: UIButton = UIButton()
    let gifButton: UIButton = UIButton()
    let reelButton: UIButton = UIButton()
    let scrollView = UIScrollView()
    let imageView: UIImageView = UIImageView()

    let slider: UISlider = UISlider()
    let sliderValueLabel = UILabel()
    var numFrames: Int = 1

    var scope: PicScopeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.PDOrange()
        
        self.button.setTitle("Camera Roll", forState: .Normal)
        self.button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        self.button.addTarget(self, action: "buttonWasPressed", forControlEvents: .TouchUpInside)
        
        self.gifButton.setTitle("Gif".uppercaseString, forState: .Normal)
        self.gifButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.gifButton.addTarget(self, action: "gifWasPressed", forControlEvents: .TouchUpInside)
        self.gifButton.backgroundColor = UIColor.PDPurple()
        self.gifButton.titleLabel?.font = UIFont.boldFont(withSize: 32)

        self.reelButton.setTitle("Reel".uppercaseString, forState: .Normal)
        self.reelButton.setTitleColor(UIColor.PDPurple(), forState: .Normal)
        self.reelButton.addTarget(self, action: "reelWasPressed", forControlEvents: .TouchUpInside)
        self.reelButton.backgroundColor = UIColor.PDOrange()
        self.reelButton.titleLabel?.font = UIFont.boldFont(withSize: 32)
        
        self.scope = PicScopeView()
        
        self.imageView.userInteractionEnabled = true
        let pinchImage = UIPinchGestureRecognizer(target: self, action: "boxWasPinched:")
        self.imageView.addGestureRecognizer(pinchImage)

        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        
        self.imageView.image = UIImage(named: "bee-test-image")
        
        self.slider.addTarget(self, action: "sliderDidSlide:", forControlEvents: UIControlEvents.ValueChanged)
        self.slider.minimumValue = 1
        self.slider.maximumValue = 8
        self.slider.value = 4
        self.sliderValueLabel.text = "4"


        
        self.modalTransitionStyle = .CoverVertical
       
        self.view.addSubview(self.scrollView)
        
        self.scrollView.addSubview(self.imageView)
        self.view.addSubview(self.button)
        self.view.addSubview(self.gifButton)
        self.view.addSubview(self.reelButton)
        self.view.addSubview(self.scope)
        self.view.addSubview(self.slider)
        self.view.addSubview(self.sliderValueLabel)
    
    }
    
    func sliderDidSlide(slider: UISlider) {
        let roundedValue = round(slider.value)
        slider.setValue(roundedValue, animated: false)
        self.sliderValueLabel.text = "\(roundedValue)"
        self.scope.numberOfSteps = Int(roundedValue)
    }
    
    func buttonWasPressed() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    private func snapshotImages() -> [UIImage]? {
        guard let image = self.imageView.image else { return nil }
        
        var baseRect = self.scrollView.frame
        baseRect.x += self.scrollView.contentOffset.x
        baseRect.y += self.scrollView.contentOffset.y
        let croppedByScrollview: UIImage = image.cropped(inRect: baseRect)
        return self.scope.frames.map { (rect: CGRect) -> UIImage in
            return croppedByScrollview
                .cropped(inRect: rect)
                .resized(toSize: baseRect.size)
        }
    }
    
    private func makeGif() -> UIImage? {
        let time = Double(4 / self.slider.value)
        if let images = self.snapshotImages(), data = Gif.makeData(images, delay: time) {
            return UIImage.gifWithData(data)
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
    
    func boxWasPinched(pinch: UIPinchGestureRecognizer) {
        guard let view = pinch.view else { return }
        view.transform = CGAffineTransformScale(view.transform, pinch.scale, pinch.scale)
        if view.height < self.scrollView.height {
            let scale = self.scrollView.height / view.height
            view.transform = CGAffineTransformScale(view.transform, scale, scale)
        }
        pinch.scale = 1

    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.imageView.image = image
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        

        self.scrollView.width = self.view.width
        self.scrollView.height = self.view.width
        
        self.imageView.sizeToFit()
        self.scrollView.contentSize = self.imageView.size
        
        self.slider.sizeToFit()
        self.slider.width = self.view.width
        self.slider.moveBelow(siblingView: self.scrollView, margin: 10, alignment: .Center)
        
        self.sliderValueLabel.sizeToFit()
        self.sliderValueLabel.moveBelow(siblingView: self.slider, margin: 2, alignment: .Center)

        self.button.sizeToFit()
        self.button.moveBelow(siblingView: self.sliderValueLabel, margin: 10, alignment: .Center)
        
        let buttonSize = CGSize(width: self.view.width / 2, height: 80)
        self.gifButton.size = buttonSize
        self.gifButton.alignBottom(0, toView: self.view)
        
        self.reelButton.size = buttonSize
        self.reelButton.moveRight(siblingView: self.gifButton, margin: 0, alignVertically: true)
        
        self.scope.frame = CGRect(CGPoint.zero, self.scrollView.size)
        if self.scope.innerRect == CGRect.zero {
            self.scope.innerRect = CGRect(100, 100, 100, 100)
        }
        
    }
}
