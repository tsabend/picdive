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

    let box: CropSquareView = CropSquareView(frame: CGRect.zero)
    let slider: UISlider = UISlider()
    let sliderValueLabel = UILabel()
    var numFrames: Int = 1
    
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
        
        let pan = UIPanGestureRecognizer(target: self, action: "boxWasMoved:")
        self.box.addGestureRecognizer(pan)
        
        
        let pinch = UIPinchGestureRecognizer(target: self, action: "boxWasPinched:")
        self.box.addGestureRecognizer(pinch)
        
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
        self.view.addSubview(self.box)
        self.view.addSubview(self.slider)
        self.view.addSubview(self.sliderValueLabel)
        

    }
    
    func sliderDidSlide(slider: UISlider) {
        let roundedValue = round(slider.value)
        slider.setValue(roundedValue, animated: false)
        self.sliderValueLabel.text = "\(roundedValue)"
        self.box.numberOfBoxes = Int(roundedValue)
        self.generateBoxes()
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
        return self.buildRects().map { (rect: CGRect) -> UIImage in
            return croppedByScrollview
                .cropped(inRect: rect)
                .resized(toSize: baseRect.size)
        }
    }
    
    private func buildRects() -> [CGRect] {
        let firstRect = self.scrollView.frame
        let endRect = self.box.frame
        
        // They are both squares, so we will use their height to determine the ratio
        let percentage = endRect.height / firstRect.height
        let numberOfSteps = Int(self.slider.value)
    
        let xDiff = endRect.x
        let yDiff = endRect.y
        
        return Array(0...numberOfSteps).map { (i: Int) -> CGRect in
            let scale = 1 - (((1 - percentage) / CGFloat(numberOfSteps)) * CGFloat(i))
            let size = CGSize(width: firstRect.width * scale, height: firstRect.height * scale)
            let originShift = CGFloat(i) / CGFloat(numberOfSteps)
            let x = xDiff * originShift
            let y = yDiff * originShift
            return CGRect(origin: CGPoint(x: x, y: y), size: size)
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
    
    func boxWasMoved(pan: UIPanGestureRecognizer) {
        guard let view = pan.view else { return }
        let superview = self.scrollView
        if pan.state == .Changed || pan.state == .Ended {
            let superviewSize = superview.size
            let viewSize = view.size
            let translation = pan.translationInView(self.view)
            var center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
            var resetTranslation = CGPoint(x: translation.x, y: translation.y)
            if center.x - viewSize.width / 2 < 0 {
                center.x = viewSize.width / 2
            } else if center.x + viewSize.width / 2 > superviewSize.width{
                center.x = superviewSize.width - viewSize.width / 2
            } else {
                resetTranslation.x = 0
            }

            if center.y - viewSize.height / 2 < 0 {
                center.y = viewSize.height / 2
            } else if center.y + viewSize.height / 2 > superviewSize.height{
                center.y = superviewSize.height - viewSize.height / 2
            } else {
                resetTranslation.y = 0
            }
            view.center = center
            self.generateBoxes()
            pan.setTranslation(CGPoint.zero, inView: self.view)
            
        }
    }

    var boxes: [UIView] = []
    func generateBoxes() {
        self.boxes.forEach {$0.removeFromSuperview() }
        self.boxes = self.buildRects().map { (rect) -> UIView in
            let view = UIView()
            view.layer.borderColor = UIColor.grayColor().CGColor
            view.layer.borderWidth = 2
            view.frame = rect
            view.userInteractionEnabled = false
            self.view.addSubview(view)
            return view
        }
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
        
        self.box.frame.size = CGSize(width: 100, height: 100)
        
    }
}
