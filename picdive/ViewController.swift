//
//  ViewController.swift
//  picdive
//
//  Created by Sean on 2/17/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit
import SwiftGifOrigin

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let button: UIButton = UIButton()
    let snapshotButton: UIButton = UIButton()
    let gifButton: UIButton = UIButton()
    let reelButton: UIButton = UIButton()
    let imageView: UIImageView = UIImageView()

    let box: CropSquareView = CropSquareView(frame: CGRect.zero)
    let slider: UISlider = UISlider()
    var numFrames: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.PDOrange()
        
        self.button.setTitle("Camera Roll", forState: .Normal)
        self.button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        self.button.addTarget(self, action: "buttonWasPressed", forControlEvents: .TouchUpInside)
        
        self.snapshotButton.setTitle("SnapShot", forState: .Normal)
        self.snapshotButton.setTitleColor(UIColor.purpleColor(), forState: .Normal)
        self.snapshotButton.addTarget(self, action: "snapShotWasPressed", forControlEvents: .TouchUpInside)
        
        self.gifButton.setTitle("Gif", forState: .Normal)
        self.gifButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        self.gifButton.addTarget(self, action: "gifWasPressed", forControlEvents: .TouchUpInside)

        self.reelButton.setTitle("Reel", forState: .Normal)
        self.reelButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        self.reelButton.addTarget(self, action: "reelWasPressed", forControlEvents: .TouchUpInside)
        
        
        let pan = UIPanGestureRecognizer(target: self, action: "boxWasMoved:")
        self.box.addGestureRecognizer(pan)
        
        
        let pinch = UIPinchGestureRecognizer(target: self, action: "boxWasPinched:")
        self.box.addGestureRecognizer(pinch)

        self.imageView.image = UIImage(named: "bee-test-image")
        
        self.slider.addTarget(self, action: "sliderDidSlide:", forControlEvents: UIControlEvents.ValueChanged)
        self.slider.minimumValue = 1
        self.slider.maximumValue = 5
        self.slider.value = 4
        
        self.view.addSubview(self.imageView)
        self.view.addSubview(self.button)
        self.view.addSubview(self.snapshotButton)
        self.view.addSubview(self.gifButton)
        self.view.addSubview(self.reelButton)
        self.view.addSubview(self.box)
        self.view.addSubview(self.slider)
    }
    
    func sliderDidSlide(slider: UISlider) {
        let roundedValue = round(slider.value)
        slider.setValue(roundedValue, animated: false)
        self.box.numberOfBoxes = Int(roundedValue)
        self.box.setNeedsDisplay()
    }
    
    func buttonWasPressed() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func snapShotWasPressed() {
        guard let image = self.imageView.image else { return }
        
        let images = self.box.rects.map { (rect: CGRect) -> UIImage in
            
            return image
                .resized(toSize: self.imageView.size)
                .cropped(inRect: rect)
        }

        let stitchedImage = UIImage.stitchImages(images)
        self.reel = stitchedImage

        if let data = Gif.makeData(images, delay: 1) {
            let gif = UIImage.gifWithData(data)
            self.gif = gif
        }
    }
    

    var gif: UIImage?
    var reel: UIImage?
    
    func gifWasPressed() {
        self.modalTransitionStyle = .CoverVertical
        let vc = GifViewController()
        vc.gif = self.gif
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func reelWasPressed() {
        self.modalTransitionStyle = .CoverVertical
        let vc = ReelViewController()
        vc.reel = self.reel
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func boxWasMoved(pan: UIPanGestureRecognizer) {
        let point = pan.locationInView(self.view)
        self.box.center = point
    }
    
    func boxWasPinched(pinch: UIPinchGestureRecognizer) {
        guard let view = pinch.view else { return }
        view.transform = CGAffineTransformScale(view.transform, pinch.scale, pinch.scale)
        pinch.scale = 1;
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.imageView.image = image
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let sideLength: CGFloat = 200
        let imageSize = CGSize(width: sideLength, height: sideLength)
        
        self.imageView.width = self.view.width
        self.imageView.height = self.view.height / 2
        
        
        self.slider.sizeToFit()
        self.slider.width = self.view.width
        self.slider.moveBelow(siblingView: self.imageView, margin: 10, alignment: .Center)

        self.button.sizeToFit()
        self.button.moveBelow(siblingView: self.slider, margin: 10, alignment: .Center)
        
        self.snapshotButton.sizeToFit()
        self.snapshotButton.moveBelow(siblingView: self.button, margin: 10, alignment: .Center)
        
        self.gifButton.sizeToFit()
        self.gifButton.moveBelow(siblingView: self.snapshotButton, margin: 10, alignment: .Center)
        
        self.reelButton.sizeToFit()
        self.reelButton.moveBelow(siblingView: self.gifButton, margin: 10, alignment: .Center)
                
        self.box.frame.size = CGSize(width: 300, height: 300)
        
    }


}
