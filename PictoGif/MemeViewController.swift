//
//  MemeViewController.swift
//  PictoGif
//
//  Created by Thomas Abend on 7/14/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

class MemeViewController: UIViewController {
    let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: ImagePickerFlowLayout())
    
    var gif: Gif!
    var completion: ((Gif) -> Void)?
    let titleLabel = UILabel()
    let textField = UITextField()
    let applyButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.PDDarkGray()
        self.title = "DANK MEMES 4EVA"
        self.setupNavigationBar()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.collectionView.registerClass(ImageCell.self, forCellWithReuseIdentifier: String(ImageCell.self))
        self.collectionView.backgroundColor = UIColor.PDDarkGray()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.allowsMultipleSelection = true
    
        self.titleLabel.text = "Add text"
        self.titleLabel.font = UIFont.PDFont(withSize: 14)
        self.titleLabel.textColor = UIColor.PDLightGray()
        
        self.textField.backgroundColor = UIColor.whiteColor()
        
        self.applyButton.setTitle("Apply", forState: .Normal)
        self.applyButton.addTarget(self, action: #selector(MemeViewController.applyText), forControlEvents: .TouchUpInside)
        self.applyButton.titleLabel?.font = UIFont.PDFont(withSize: 14)
        
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.applyButton)
        self.view.addSubview(self.textField)
    }
    
    func setupNavigationBar() {
        self.navigationItem.leftBarButtonItem = BarButtonItem(image: BarButtonItem.cancelImage) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let yOrigin: CGFloat = self.navigationController?.navigationBar.maxY ?? 0
        
        self.collectionView.width = self.view.width / 4
        self.collectionView.height = self.view.height - 32 - yOrigin
        self.collectionView.origin = CGPoint(8, yOrigin + 16)
        
        let rightCenter = (self.view.width - self.collectionView.maxX) / 2 + self.collectionView.maxX
        self.titleLabel.sizeToFit()
        self.titleLabel.center.x = rightCenter
        self.titleLabel.y = yOrigin + 16
        
        self.textField.sizeToFit()
        self.textField.width = self.view.width - self.collectionView.maxX - 16
        self.textField.moveBelow(siblingView: self.titleLabel, margin: 8, alignment: .Center)
        
        self.applyButton.sizeToFit()
        self.applyButton.moveBelow(siblingView: self.textField, margin: 8, alignment: .Center)
        
    }
    
    func applyText() {
        guard let text = self.textField.text else { return }
        guard let idxPaths = self.collectionView.indexPathsForSelectedItems() else { return }
        let images = self.gif.images.enumerate().map { (idx, image) -> UIImage in
            if idxPaths.contains({ $0.row == idx }) {
                return image.meme(withText: text)
            }
            return image
        }
        let gif = Gif(images: images, easing: self.gif.easing, totalTime: self.gif.totalTime)
        
        self.completion?(gif)
    }
    
}

// MARK: - CollectionView
extension MemeViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.gif.images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier(String(ImageCell.self), forIndexPath: indexPath) as? ImageCell {
            let image = self.gif.images[indexPath.row]
            cell.imageView.image = image
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
       print("whabang")
    }
}