
//
//  ImagePickerViewController.swift
//  picdive
//
//  Created by Thomas Abend on 4/7/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit
import Photos

/// Initial View Controller. 
class ImagePickerViewController: UIViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    // MARK: - Properties
    private let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: ImagePickerFlowLayout())
    private let cameraButton = UIButton()
    private let cameraRollButton = UIButton()
    private let footerView = UIView()
    private let noImagePlaceholder = UIImageView()
    private let imageCropper = ImageCropper()
    private var photoRetriever = PhotoRetriever()
    
    // MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Pick Your Image"

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
        
        self.queryPhotos()
       
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
        
        self.cameraButton.setImage(UIImage(named: "camera"), forState: .Normal)
        self.cameraButton.addTarget(self, action: #selector(ImagePickerViewController.cameraWasPressed), forControlEvents: .TouchUpInside)
        
        self.cameraRollButton.setTitle("Camera Roll", forState: .Normal)
        self.cameraRollButton.titleLabel?.font = UIFont.PDFont(withSize: 17)
        self.cameraRollButton.addTarget(self, action: #selector(ImagePickerViewController.cameraRollWasPressed), forControlEvents: .TouchUpInside)
        
        self.noImagePlaceholder.image = UIImage(named: "logo")
        
        self.footerView.backgroundColor = UIColor.PDDarkGray()
        
        self.view.addSubview(self.footerView)
        self.footerView.addSubview(self.cameraButton)
        self.footerView.addSubview(self.cameraRollButton)
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.noImagePlaceholder)
        self.view.addSubview(self.imageCropper)
        
        self.pan.delegate = self
        self.view.addGestureRecognizer(self.pan)
        
        self.imageCropper.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ImagePickerViewController.expandView)))
    }
    
    lazy var cancelButton: BarButtonItem = {
        return BarButtonItem(image: BarButtonItem.cancelImage) { [weak self] in
            self?.imageCropper.image = nil
            self?.setupNavigationBar()
        }
    }()
    
    lazy var nextButton: BarButtonItem = BarButtonItem(image: BarButtonItem.nextImage) { [weak self] in self?.toNext() }
    
    func setupNavigationBar() {
        if self.imageCropper.image != nil {
            self.navigationItem.leftBarButtonItem = self.cancelButton
            self.navigationItem.rightBarButtonItem = self.nextButton
        } else {
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = nil
        }
    }

    lazy var cropperYOrigin: CGFloat = self.navigationController?.navigationBar.maxY ?? 0
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let originalY = self.isCollapsed ? -Config.imageViewWidth + 112 : self.cropperYOrigin
        self.imageCropper.darkness = self.isCollapsed ? 1 : 0
        
        self.imageCropper.y = originalY
        if self.imageCropper.size == CGSize.zero {
            self.imageCropper.size = CGSize(Config.imageViewWidth, Config.imageViewWidth)
            self.imageCropper.moveToHorizontalCenterOfSuperview()
        }
        
        self.noImagePlaceholder.size = CGSize(150, 78)
        self.noImagePlaceholder.center = self.imageCropper.center
        
        
        self.collectionView.size = self.view.size
        self.collectionView.moveBelow(siblingView: self.imageCropper, margin: 0)
        
        self.cameraButton.size = CGSize(32, 32)
        self.cameraButton.moveToCenterOfSuperview()
        
        self.cameraRollButton.sizeToFit()
        self.cameraRollButton.origin = CGPoint(16, 4)
        
        self.footerView.size = CGSize(width: self.view.width, height: 32)
        self.footerView.alignBottom(0, toView: self.view)
        self.view.bringSubviewToFront(self.footerView)
        
    }
    
    
    // MARK: - Actions
    func selectImage(image: UIImage) {
        self.expandView()
        self.imageCropper.image = image
        self.setupNavigationBar()
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
    var beginningY: CGFloat?
    var panBeganInCollection: Bool = false
    /// Manages transitions of the view between collapsed and expanded states
    func viewWasPanned(pan: UIPanGestureRecognizer) {
        let currentPoint = pan.locationInView(self.view)
        let hitInsideCollection = self.view.hitTest(currentPoint, withEvent: nil)?.closest(UICollectionView.self) != nil
        let sign: CGFloat = self.isCollapsed ? -1 : 1
        
        switch pan.state {
        case .Began:
            // Expanded must begin in the collection
            if !self.isCollapsed && !hitInsideCollection { return }
            self.panBeganInCollection = hitInsideCollection
            self.beginningY = currentPoint.y
        case .Changed:
            // The gesture had a valid beginning
            guard self.beginningY != nil else { return }
            let delta = pan.translationInView(self.view).y
            let scrollingDown = delta > 0
            
            // You are currently scrolling up outside the collectionView
            let shouldScrollUp = !hitInsideCollection && !scrollingDown
            // In the expanded state, you are scrolling down
            let scrollDownExpanded = !self.isCollapsed && scrollingDown
            // In the collapsed state, you started outside the collection and are now scrolling down
            let shouldScrollDownOutsideCollection = self.isCollapsed && !self.panBeganInCollection && scrollingDown
            // In the collapsed state, you are scrolling in the collectionView and the collectionView is at its top.
            let shouldScrollDownInsideCollection = self.isCollapsed &&
                hitInsideCollection && scrollingDown && self.collectionView.contentOffset.y <= 0
            
            
            if shouldScrollUp || shouldScrollDownInsideCollection || shouldScrollDownOutsideCollection || scrollDownExpanded {
                // Bail if you're dragging the cropper too far
                if self.imageCropper.y + delta > self.cropperYOrigin { return }
                // Move the views up
                let animatingViews = [self.imageCropper, self.noImagePlaceholder, self.collectionView]
                animatingViews.forEach({$0.y += delta})
                self.imageCropper.darkness -= delta/400
            }
            
            pan.setTranslation(CGPoint.zero, inView: self.view)
            
        case .Ended, .Cancelled, .Failed:
            // You are just scrolling through your photos
            let collectionScrolling = (self.isCollapsed && self.panBeganInCollection && self.collectionView.contentOffset.y > 0) || self.imageCropper.y == self.cropperYOrigin
            
            // Toggle collapsed
            if !collectionScrolling {
                
                let totalDelta = ((self.beginningY ?? currentPoint.y) - currentPoint.y)
                let threshhold = 0.3 * UIScreen.mainScreen().bounds.width
                if totalDelta * sign > (threshhold) {
                    self.isCollapsed = !self.isCollapsed
                }
            }
            
            // Animate the view
            UIView.animateWithDuration(0.25) {
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
            // Clear the state
            self.beginningY = nil
            self.panBeganInCollection = false
        default:
            break
        }
    }
    
    func expandView() {
        guard self.isCollapsed else { return }
        self.isCollapsed = false
        UIView.animateWithDuration(0.25) {
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
        return self.photoRetriever.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier(String(ImageCell.self), forIndexPath: indexPath) as? ImageCell {
            self.photoRetriever.getThumb(atIndex: indexPath.item) { (image) in
                cell.imageView.image = image
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let asset = self.photoRetriever[indexPath.item] else { return }
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
        self.presentImagePicker(withSourceType: .Camera)
    }
    
    func cameraRollWasPressed() {
        self.presentImagePicker(withSourceType: .PhotoLibrary)
    }
    
    private func presentImagePicker(withSourceType sourceType: UIImagePickerControllerSourceType) {
        let vc = UIImagePickerController()
        vc.sourceType = sourceType
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

// MARK: - Photo Retrieving
extension ImagePickerViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(changeInstance: PHChange) {
        self.queryPhotos()
    }
    
    func queryPhotos() {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == PHAuthorizationStatus.Denied {
            let vc = UIAlertController(title: "Oh no!", message: "You have not given us access to your photos. Go to your settings and enable photo access to get the most out of PictoGif", preferredStyle: .Alert)
            vc.addAction(UIAlertAction(title: "Go to settings", style: .Default, handler: { (_) in
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            }))
            vc.addAction(UIAlertAction(title: "Not now", style: .Default, handler: nil))
            self.presentViewController(vc, animated: true, completion: nil)

        }
        self.photoRetriever.reloadData()
        immediately { self.collectionView.reloadData() }        
        if let first = self.photoRetriever[0] where self.imageCropper.image == nil {
            self.photoRetriever.getImage(first) { (image) in
                if let image = image {
                    immediately { self.selectImage(image) }
                }
            }
        }
    }
}
