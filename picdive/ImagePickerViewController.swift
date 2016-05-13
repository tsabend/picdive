
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

class ImagePickerViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: ImagePickerFlowLayout())
    private var photos: [(UIImage?, PHAsset)] = []
    private let cameraButton = UIButton()
    private let headerView = UIView()
    private let noImagePlaceholder = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Select an image"
        
        self.view.backgroundColor = UIColor.PDLightGray()
        self.headerView.backgroundColor = UIColor.PDDarkGray()
        self.collectionView.backgroundColor = UIColor.PDDarkGray()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.registerClass(ImageCell.self, forCellWithReuseIdentifier: String(ImageCell.self))
        
        PhotoRetriever().queryPhotos { (images) in
            guard let images = images else { return }
            self.photos = images
        }
        
        self.cameraButton.setTitle("Take a Photo 📸", forState: .Normal)
        self.cameraButton.addTarget(self, action: #selector(ImagePickerViewController.cameraWasPressed), forControlEvents: .TouchUpInside)
        
        self.noImagePlaceholder.image = UIImage(named: "enhance_icon")
        
        self.view.addSubview(self.headerView)
        self.headerView.addSubview(self.cameraButton)
        self.view.addSubview(self.collectionView)
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
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let asset = self.photos[indexPath.item].1
        PhotoRetriever().getImage(asset) { image in
            if let image = image {
                self.selectImage(image)
            }
        }
    }
    
    func selectImage(image: UIImage) {
        let vc = CroppingViewController()
        vc.imageViewDataSource = image
        self.navigationController?.pushViewController(vc, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.noImagePlaceholder.size = CGSize(width: 176, height: 89)
        self.noImagePlaceholder.center.x = self.view.center.x
        self.noImagePlaceholder.y = (self.view.width - self.noImagePlaceholder.height) / 2
        
        self.collectionView.size = CGSize(self.view.width, self.view.maxY - self.view.width - 64)
        self.collectionView.alignBottom(0, toView: self.view)
        
        self.headerView.size = CGSize(width: self.view.width, height: 64)
        self.headerView.y = self.collectionView.y - self.headerView.height
        
        self.cameraButton.sizeToFit()
        self.cameraButton.moveToCenterOfSuperview()
    }
}

class ImagePickerFlowLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = 0
        let itemSideLength = UIScreen.mainScreen().bounds.width / 4
        self.itemSize = CGSize(width: itemSideLength, height: itemSideLength)
        self.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
       fatalError("coder")
    }
    

}

