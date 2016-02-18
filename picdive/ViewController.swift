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
    let box: UIView = UIView()
    
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
        
        self.box.layer.borderColor = UIColor.blackColor().CGColor
        self.box.layer.borderWidth = 4

        self.snapshotImageView.layer.borderColor = UIColor.blackColor().CGColor
        self.snapshotImageView.layer.borderWidth = 4
        
        self.view.addSubview(self.imageView)
        self.view.addSubview(self.button)
        self.view.addSubview(self.snapshotButton)
        self.view.addSubview(self.box)
        self.view.addSubview(self.snapshotImageView)
    }
    
    func buttonWasPressed() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func snapShotWasPressed() {
        UIGraphicsBeginImageContext(self.box.frame.size)

        if let context = UIGraphicsGetCurrentContext() {

            let clippedRect = CGRect(x: 0, y: 0, width: self.box.width, height: self.box.height)
            
            CGContextClipToRect(context, clippedRect)
            
            let drawRect = CGRect(x: -1 * self.box.frame.origin.x, y: -1 * self.box.frame.origin.y, width: self.imageView.width, height: self.imageView.height)
            
            CGContextDrawImage(context, drawRect, imageView.image?.CGImage)
            
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        self.snapshotImageView.alpha = 0
        self.snapshotImageView.frame.origin.x = self.view.frame.maxX
        self.snapshotImageView.image = image
        UIView.animateWithDuration(3) {
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
        
        self.box.frame.size = CGSize(width: 100, height: 100)
        
        self.snapshotImageView.frame = CGRect(x: 0, y: self.view.bounds.maxY - 100, width: 100, height: 100)
    }


}


extension UIView {
    var width: CGFloat {
        get { return self.frame.width }
        set { self.frame.size.width = newValue }
    }

    var height: CGFloat {
        get { return self.frame.height }
        set { self.frame.size.height = newValue }
    }

}

