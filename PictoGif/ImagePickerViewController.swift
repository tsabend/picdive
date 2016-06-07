
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

class ImagePickerViewController: UIViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    private let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: ImagePickerFlowLayout())
    private var photos: [(UIImage?, PHAsset)] = []
    private let cameraButton = UIButton()
    private let footerView = UIView()
    private let noImagePlaceholder = UIImageView()
    private let imageCropper = ImageCropper()
    
    // MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Pick Your Image"

        let cancelButton = BarButtonItem(image: BarButtonItem.cancelImage) { [weak self] in self?.imageCropper.image = nil }
        let nextButton = BarButtonItem(image: BarButtonItem.nextImage) { [weak self] in self?.toNext() }
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = nextButton

        PicDiveProducts.store.requestProducts{success, products in
            if success {
             print(products)
            }
        }
    
        self.view.backgroundColor = UIColor.PDDarkGray()
        self.collectionView.backgroundColor = UIColor.PDDarkGray()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.contentInset = UIEdgeInsetsZero
        self.automaticallyAdjustsScrollViewInsets = false
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
        
        self.cameraButton.setImage(UIImage(named: "camera")?.resized(toSize: CGSize(22, 22)), forState: .Normal)
        self.cameraButton.addTarget(self, action: #selector(ImagePickerViewController.cameraWasPressed), forControlEvents: .TouchUpInside)
        
        self.noImagePlaceholder.image = UIImage(named: "logo")
        
        self.footerView.backgroundColor = UIColor.PDDarkGray()
        
        self.view.addSubview(self.footerView)
        self.footerView.addSubview(self.cameraButton)
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.noImagePlaceholder)
        self.view.addSubview(self.imageCropper)
        
        self.pan.delegate = self
        self.view.addGestureRecognizer(self.pan)
        
        self.imageCropper.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ImagePickerViewController.cropperWasTapped)))
    }

    lazy var cropperYOrigin: CGFloat = self.navigationController?.navigationBar.maxY ?? 0
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let originalY = self.isCollapsed ? -self.view.width + 96 : self.cropperYOrigin
        self.imageCropper.darkness = self.isCollapsed ? 1 : 0
        
        self.imageCropper.y = originalY
        if self.imageCropper.size == CGSize.zero {
            self.imageCropper.size = CGSize(self.view.width, self.view.width)
        }
        
        self.noImagePlaceholder.size = CGSize(150, 78)
        self.noImagePlaceholder.center = self.imageCropper.center
        
        
        self.collectionView.size = self.view.size
        self.collectionView.moveBelow(siblingView: self.imageCropper, margin: 0)
        
        self.cameraButton.size = CGSize(44, 44)
        self.cameraButton.moveToCenterOfSuperview()
        
        self.footerView.size = CGSize(width: self.view.width, height: 44)
        self.footerView.alignBottom(0, toView: self.view)
        self.view.bringSubviewToFront(self.footerView)
        
    }
    
    
    // MARK: - Actions
    func selectImage(image: UIImage) {
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
    
    // MARK: - Gestures
    lazy var pan: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ImagePickerViewController.viewWasPanned))
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (gestureRecognizer == self.pan && otherGestureRecognizer == self.collectionView.panGestureRecognizer)
            || (gestureRecognizer == self.pan && otherGestureRecognizer == self.imageCropper.panGestureRecognizer && self.isCollapsed)
    }
    
    var isCollapsed: Bool = false
    var beginningY: CGFloat?, previousY: CGFloat?
    /// Manages transitions of the view between collapsed and expanded states
    func viewWasPanned(pan: UIPanGestureRecognizer) {
        let currentPoint = pan.locationInView(self.view)
        let hitInCropper = self.view.hitTest(currentPoint, withEvent: nil)?.closest(ImageCropper.self) != nil
        
        switch pan.state {
        case .Began:
            // Collapsed must begin in cropper and vice-versa
            guard hitInCropper == self.isCollapsed else { return }
            self.beginningY = currentPoint.y
            self.previousY = currentPoint.y
        case .Changed:
            // The gesture had a valid beginning
            guard let previousY = self.previousY else { return }
            
            if hitInCropper || self.isCollapsed {
                let delta = currentPoint.y - previousY
                // Bail if you're dragging the cropper too far down
                if self.imageCropper.y + delta > self.cropperYOrigin { return }
                // Darken/Lighten the image
                self.imageCropper.darkness -= delta/1000
                // Move the views up
                let animatingViews = [self.imageCropper, self.noImagePlaceholder, self.collectionView]
                animatingViews.forEach({$0.y += delta})
            }
            
            self.previousY = currentPoint.y
            
        case .Ended, .Cancelled, .Failed:
            // Toggle collapsed
            let sign: CGFloat = self.isCollapsed ? -1 : 1
            let totalDelta = ((self.beginningY ?? currentPoint.y) - currentPoint.y)
            let threshhold = 0.3 * UIScreen.mainScreen().bounds.width
            if totalDelta * sign > (threshhold) {
                self.isCollapsed = !self.isCollapsed
            }
            // Animate the view
            UIView.animateWithDuration(0.33) {
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
            // Clear the state
            self.beginningY = nil
            self.previousY = nil
            
        default:
            break
        }
    }
    
    func cropperWasTapped(tap: UITapGestureRecognizer) {
        guard self.isCollapsed else { return }
        self.isCollapsed = false
        UIView.animateWithDuration(0.33) {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - CollectionView
extension ImagePickerViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
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
}

// MARK: - UIImagePickerControllerDelegate
extension ImagePickerViewController: UIImagePickerControllerDelegate {
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

}

class ImagePickerFlowLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        
        let interItemSpacing: CGFloat = 4
        self.minimumInteritemSpacing = interItemSpacing
        self.minimumLineSpacing = 4
        let itemSideLength = (UIScreen.mainScreen().bounds.width / 4) - interItemSpacing
        self.itemSize = CGSize(width: itemSideLength, height: itemSideLength)
        self.sectionInset = UIEdgeInsets(top: 1, left: 0, bottom: 4, right: 0)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
       fatalError("coder")
    }
    
}

