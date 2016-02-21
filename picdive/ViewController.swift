//
//  ViewController.swift
//  picdive
//
//  Created by Sean on 2/17/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let button: UIButton = UIButton()
    let snapshotButton: UIButton = UIButton()
    let imageView: UIImageView = UIImageView()
    let snapshotImageView = UIImageView()
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
        
        let pan = UIPanGestureRecognizer(target: self, action: "boxWasMoved:")
        self.box.addGestureRecognizer(pan)
        
        let pinch = UIPinchGestureRecognizer(target: self, action: "boxWasPinched:")
        self.box.addGestureRecognizer(pinch)
        

        self.snapshotImageView.layer.borderColor = UIColor.blackColor().CGColor
        self.snapshotImageView.layer.borderWidth = 4
        
        self.snapshotImageView.contentMode = .Center
        
        self.slider.addTarget(self, action: "sliderDidSlide:", forControlEvents: UIControlEvents.ValueChanged)
        self.slider.minimumValue = 1
        self.slider.maximumValue = 5
        
        self.view.addSubview(self.imageView)
        self.view.addSubview(self.button)
        self.view.addSubview(self.snapshotButton)
        self.view.addSubview(self.box)
        self.view.addSubview(self.snapshotImageView)
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
        
        let crop = image
            .resized(toSize: self.imageView.size)
            .cropped(inRect: self.box.frame)

        self.snapshotImageView.alpha = 0
        self.snapshotImageView.image = crop
        self.snapshotImageView.frame.origin.x = self.view.frame.maxX
        UIView.animateWithDuration(0.3) {
            self.snapshotImageView.alpha = 1
            self.snapshotImageView.frame.origin.x = 0
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
        
        
        self.imageView.width = self.view.width
        self.imageView.height = self.view.height / 2

        self.button.sizeToFit()
        self.button.center = self.view.center
        self.button.frame.origin.y = self.imageView.frame.maxY + 100
        
        self.snapshotButton.sizeToFit()
        self.snapshotButton.center = self.view.center
        self.snapshotButton.frame.origin.y = self.imageView.frame.maxY + 70
        
        self.slider.sizeToFit()
        self.slider.width = self.view.width
        self.slider.frame.origin.y = self.view.height / 2 - 40
        
        self.box.frame.size = CGSize(width: 300, height: 300)
        
        self.snapshotImageView.frame = CGRect(x: 0, y: self.view.bounds.maxY - 100, width: 100, height: 100)
    }


}
