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
    let saveButton: UIButton = UIButton()
    let shareButton: UIButton = UIButton()
    let imageView: UIImageView = UIImageView()
    let stitchView = UIImageView()
    let gifView = UIImageView()
    let box: CropSquareView = CropSquareView(frame: CGRect.zero)
    let slider: UISlider = UISlider()
    var numFrames: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.button.setTitle("Camera Roll", forState: .Normal)
        self.button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        self.button.addTarget(self, action: "buttonWasPressed", forControlEvents: .TouchUpInside)
        
        self.snapshotButton.setTitle("SnapShot", forState: .Normal)
        self.snapshotButton.setTitleColor(UIColor.purpleColor(), forState: .Normal)
        self.snapshotButton.addTarget(self, action: "snapShotWasPressed", forControlEvents: .TouchUpInside)
        
        self.saveButton.setTitle("Save", forState: .Normal)
        self.saveButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        self.saveButton.addTarget(self, action: "saveWasPressed", forControlEvents: .TouchUpInside)
        
        let pan = UIPanGestureRecognizer(target: self, action: "boxWasMoved:")
        self.box.addGestureRecognizer(pan)
        
        
        let pinch = UIPinchGestureRecognizer(target: self, action: "boxWasPinched:")
        self.box.addGestureRecognizer(pinch)

        self.imageView.image = UIImage(named: "bee-test-image")
        
        self.slider.addTarget(self, action: "sliderDidSlide:", forControlEvents: UIControlEvents.ValueChanged)
        self.slider.minimumValue = 1
        self.slider.maximumValue = 5
        
        self.view.addSubview(self.imageView)
        self.view.addSubview(self.gifView)
        self.view.addSubview(self.button)
        self.view.addSubview(self.snapshotButton)
        self.view.addSubview(self.saveButton)
        self.view.addSubview(self.box)
        self.view.addSubview(self.stitchView)
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
        self.stitchView.image = stitchedImage

        if let data = Gif.makeData(images, delay: 1) {
            let gif = UIImage.gifWithData(data)
            self.gifView.image = gif
        }
    }
    
    func saveWasPressed() {
        print("Boom")
        if let image = self.stitchView.image {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        
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
        
        self.saveButton.sizeToFit()
        self.saveButton.moveBelow(siblingView: self.snapshotButton, margin: 10, alignment: .Center)
        
        self.box.frame.size = CGSize(width: 300, height: 300)
        
        self.gifView.size = imageSize
        self.gifView.alignBottom(0, toView: self.view)
        self.gifView.alignRight(0, toView: self.view)
        
        self.stitchView.contentMode = .ScaleAspectFit
        self.stitchView.size = imageSize
        self.stitchView.alignBottom(50, toView: self.view)
    }


}
