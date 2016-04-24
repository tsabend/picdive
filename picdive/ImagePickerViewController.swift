
//
//  ImagePickerViewController.swift
//  picdive
//
//  Created by Thomas Abend on 4/7/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit
import Photos

class ImagePickerViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: ImagePickerFlowLayout())
    private var photos: [(UIImage?, PHAsset)] = []
    
    private let cameraButton = UIButton()
    private let noImagePlaceholder = UILabel()
    private let cropper = ImageCropper()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor.PDDarkGray()
        
        
        self.view.backgroundColor = UIColor.PDLightGray()
        self.collectionView.backgroundColor = UIColor.PDDarkGray()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.registerClass(ImageCell.self, forCellWithReuseIdentifier: String(ImageCell.self))
        
        PhotoRetriever().queryPhotos { (images) in
            guard let images = images else { return }
            self.photos = images
        }
        
        self.cameraButton.setTitle("📸", forState: .Normal)
        self.cameraButton.addTarget(self, action: #selector(ImagePickerViewController.cameraWasPressed), forControlEvents: .TouchUpInside)
        
        self.noImagePlaceholder.text = "Select an Image"
        self.noImagePlaceholder.textColor = UIColor.PDDarkGray()
        
        
        self.view.addSubview(self.cropper)
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.cameraButton)
        self.view.addSubview(self.noImagePlaceholder)
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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(self.view.width, 44)
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
        self.cropper.image = image
        self.noImagePlaceholder.hidden = true
        
        let barButton = UIBarButtonItem(title: "✔", style: UIBarButtonItemStyle.Done, target: self, action: #selector(ImagePickerViewController.segueToDive))
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func segueToDive() {
        let vc = ViewController()
//        let image = self.cropper.image
//        let crop = image?.cropped(inRect: cropper.bounds)
        vc.imageView.image = self.cropper.crop()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        let sideLength = UIScreen.mainScreen().bounds.width
        self.cropper.size = CGSize(width: sideLength, height: sideLength)
        
        self.noImagePlaceholder.sizeToFit()
        self.noImagePlaceholder.center = self.cropper.center
        

//        self.cameraButton.sizeToFit()
//        self.cameraButton.moveAbove(siblingView: self.collectionView, margin: 16, alignment: .Center)

        self.collectionView.frame = CGRect(0, self.cropper.maxY, self.view.width, self.view.maxY - self.cropper.maxY)
        
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
}

class ImagePickerFlowLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = 0
        let itemSideLength = UIScreen.mainScreen().bounds.width / 4
        self.itemSize = CGSize(width: itemSideLength, height: itemSideLength)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
       fatalError("coder")
    }
}

