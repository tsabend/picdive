
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
    let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: ImagePickerFlowLayout())
    let cameraButton = UIButton()
    var photos: [UIImage?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.cameraButton)
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
            cell.imageView.image = self.photos[indexPath.item]
            cell.backgroundColor = UIColor.redColor()
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let image = self.photos[indexPath.item] else { return }
        self.selectImage(image)
    }
    
    func selectImage(image: UIImage) {
        let vc = ViewController()
        vc.imageView.image = image
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.cameraButton.sizeToFit()
        
        self.collectionView.frame = CGRect(0, self.view.height * 0.2, self.view.width, self.view.height * 0.8)
        
        self.cameraButton.moveAbove(siblingView: self.collectionView, margin: 16, alignment: .Center)
    }
    
    
    
}

class ImageCell: UICollectionViewCell {
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is terrible")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.contentView.bounds
    }
    
}

class ImagePickerFlowLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        
        self.minimumInteritemSpacing = 0
        let itemSideLength = UIScreen.mainScreen().bounds.width / 4
        self.itemSize = CGSize(width: itemSideLength, height: itemSideLength)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
       fatalError("coder")
    }
}

struct PhotoRetriever {
    func queryPhotos(@noescape queryCallback: ([UIImage?]? -> Void)) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions)
        var images: [UIImage?] = []
        let contentMode: PHImageContentMode = .Default
        fetchResult.enumerateObjectsUsingBlock { (object, index, stop) in
            let options = PHImageRequestOptions()
            options.synchronous = true
            options.deliveryMode = .HighQualityFormat
            PHImageManager.defaultManager().requestImageForAsset(object as! PHAsset, targetSize: PHImageManagerMaximumSize, contentMode: contentMode, options: options) {
                image, info in
                images.append(image)
            }
        }
        queryCallback(images)
    }
}