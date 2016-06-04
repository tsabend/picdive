
//
//  ImagePickerViewController.swift
//  picdive
//
//  Created by Thomas Abend on 4/7/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit
import Photos
import pop

class ImagePickerViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    private let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: ImagePickerFlowLayout())
    private var photos: [(UIImage?, PHAsset)] = []
    private let cameraButton = UIButton()
    private let headerView = UIView()
    private let noImagePlaceholder = UIImageView()
    private let imageCropper = ImageCropper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Pick your image"
        
        self.view.backgroundColor = UIColor.PDDarkGray()
        self.collectionView.backgroundColor = UIColor.PDDarkGray()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.registerClass(ImageCell.self, forCellWithReuseIdentifier: String(ImageCell.self))
        
        PhotoRetriever().queryPhotos { (images) in
            guard let images = images else { return }
            self.photos = images
            if let first = images.first {
                PhotoRetriever().getImage(first.1) { (image) in
                    if let image = image {
                        self.selectImage(image)
                    }
                }
            }
        }
        
        self.cameraButton.setTitle("Take a Photo 📸", forState: .Normal)
        self.cameraButton.addTarget(self, action: #selector(ImagePickerViewController.cameraWasPressed), forControlEvents: .TouchUpInside)
        
//        self.noImagePlaceholder.image = UIImage(named: "enhance_icon")
        
        self.view.addSubview(self.headerView)
        self.headerView.addSubview(self.cameraButton)
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.noImagePlaceholder)
        self.view.addSubview(self.imageCropper)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(ImagePickerViewController.viewWasPanned))
        pan.delegate = self
        self.view.addGestureRecognizer(pan)
        
        self.imageCropper.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ImagePickerViewController.cropperWasTapped)))
        
        
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    private lazy var animationYDiff: CGFloat = self.imageCropper.height - 44
    
    var beginningY: CGFloat?
    var isExpanded: Bool = false
    var shouldComplete = false
    func viewWasPanned(pan: UIPanGestureRecognizer) {
        let sign: CGFloat = self.isExpanded ? -1.0 : 1.0
        let currentY = pan.locationInView(self.view).y
        let threshhold = UIScreen.mainScreen().bounds.width / 4
        let change = (self.beginningY ?? currentY) - currentY
        self.shouldComplete = self.isExpanded ? change < 0 : change > 0
        let delta = ((self.beginningY ?? currentY) - currentY) * sign
        
        switch pan.state {
        case .Began:
            self.beginningY = currentY
            self.view.subviews.forEach { $0.layer.timeOffset = 0 ; self.animateYPositon(ofView: $0, byY: -self.animationYDiff * sign) }
        case .Changed:
            
                if delta > threshhold {
                    let timeOffset =  ((delta - threshhold) / 200.0).d
                    print(timeOffset)
                    if timeOffset < 1 {
                        self.view.subviews.forEach { $0.layer.timeOffset = timeOffset }
                    }
                }
            
        case .Ended, .Cancelled, .Failed:
            if delta > threshhold && self.shouldComplete {
                self.isExpanded = !self.isExpanded
                let remainingY = self.animationYDiff - delta + (44 * -sign)
                
                self.view.subviews.forEach { view in
                    self.animateYPositon(ofView: view, byY: -sign * remainingY)
                    view.layer.timeOffset = 0
                    view.layer.position.y += -self.animationYDiff * sign
                    view.layer.speed = 4
                }
                
            } else {
                self.view.subviews.forEach {$0.layer.removeAllAnimations()}
            }
            self.beginningY = nil
        default:
            break
        }

    }
    
    func cropperWasTapped(tap: UITapGestureRecognizer) {
        if self.isExpanded {
            self.shouldComplete = true
            self.view.subviews.forEach { view in
                view.layer.timeOffset = 0;
                self.animateYPositon(ofView: view, byY: self.animationYDiff)
                view.layer.position.y = (view.layer.presentationLayer() as! CALayer).position.y + self.animationYDiff
            }
            self.view.subviews.forEach { $0.layer.speed = 3 }
            self.isExpanded = false
        }
    }

    // MARK: - Camera
    func cameraWasPressed() {
        let vc = UIImagePickerController()
        vc.sourceType = .Camera
        vc.delegate = self
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.dismissViewControllerAnimated(true, completion: nil)
            self.selectImage(image)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - CollectionView
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier(String(ImageCell.self), forIndexPath: indexPath) as? ImageCell {
            cell.imageView.image = self.photos[indexPath.item].0
            cell.backgroundColor = UIColor.redColor()
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let asset = self.photos[indexPath.item].1
        PhotoRetriever().getImage(asset) { image in
            if let image = image {
                self.selectImage(image)
            }
        }
    }
    
    
    func selectImage(image: UIImage) {
        let nextButton = BarButtonItem(title: "->") { [weak self] in self?.toNext() }
        self.navigationItem.rightBarButtonItem = nextButton
        self.imageCropper.image = image
    }
    
    func toNext() {
        if let image = self.imageCropper.crop() {
            let vc = ScopeViewController()
            vc.imageViewDataSource = image
            self.navigationController?.pushViewController(vc, animated: false)
            vc.animateIn()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !self.isExpanded {
            
            self.noImagePlaceholder.size = CGSize(width: 176, height: 89)
            self.noImagePlaceholder.center.x = self.view.center.x
            self.noImagePlaceholder.y = (self.view.width - self.noImagePlaceholder.height) / 2
            
            if self.imageCropper.size == CGSize.zero {
                self.imageCropper.size = CGSize(self.view.width, self.view.width)
                
            }
            
            self.headerView.size = CGSize(width: self.view.width, height: 64)
            self.arrangeViews()
            self.collectionView.size = self.view.size
            
            self.cameraButton.sizeToFit()
            self.cameraButton.moveToCenterOfSuperview()
        }
    }
    
    private func arrangeViews() {
        self.imageCropper.y = self.navigationController?.navigationBar.maxY ?? 0
        
        self.headerView.moveBelow(siblingView: self.imageCropper, margin: 0)
        
        self.collectionView.moveBelow(siblingView: self.headerView, margin: 0)
    }
    
    private func animateYPositon(ofView view: UIView, byY value: CGFloat, duration: Double = 1.0) {
        let animation = CABasicAnimation(keyPath: "position.y")
        let position = (view.layer.presentationLayer() as! CALayer).position.y
        animation.fromValue = position
        animation.toValue = position + value
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        view.layer.speed = 0
        let key = NSUUID().UUIDString
        view.layer.addAnimation(animation, forKey: key)
    }

}

class ImagePickerFlowLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        
        let interItemSpacing: CGFloat = 2
        self.minimumInteritemSpacing = interItemSpacing
        self.minimumLineSpacing = 0
        let itemSideLength = (UIScreen.mainScreen().bounds.width / 4) - interItemSpacing
        self.itemSize = CGSize(width: itemSideLength, height: itemSideLength)
        self.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
       fatalError("coder")
    }
    
}

