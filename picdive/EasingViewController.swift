//
//  EasingViewController.swift
//  picdive
//
//  Created by Thomas Abend on 5/8/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

class EasingViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var label = UILabel()
    var collectionView: UICollectionView!
    var easings: [EasingType] = []
    var onClick: (EasingType? -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let flowLayout = EasingFlowLayout()
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.collectionView.registerClass(EasingCell.self, forCellWithReuseIdentifier: String(EasingCell.self))
        self.collectionView.backgroundColor = UIColor.clearColor()
        self.collectionView.showsHorizontalScrollIndicator = false
        
        self.label.textColor = UIColor.PDLightGray()
        self.view.addSubview(self.label)
        self.view.addSubview(self.collectionView)
        

    }
    
    // MARK: - CollectionView
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.easings.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier(String(EasingCell.self), forIndexPath: indexPath) as? EasingCell {
            let easing = self.easings[indexPath.row]
            cell.label.text = easing.label
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.onClick?(self.easings[safe: indexPath.row])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.label.sizeToFit()
        self.label.moveToHorizontalCenter(ofView: self.view)
        self.collectionView.size = CGSize(self.view.width, self.view.height - self.label.height)
        self.collectionView.moveBelow(siblingView: self.label, margin: 0)
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        super.didMoveToParentViewController(parent)
        self.collectionView.contentInset = UIEdgeInsetsZero
        self.collectionView.invalidateIntrinsicContentSize()
        self.collectionView.reloadData()
        after(seconds: 0.1) {
            
            self.collectionView.selectItemAtIndexPath(NSIndexPath(forItem: 0,inSection: 0), animated: false, scrollPosition: .None)
        }
    }
}

class EasingFlowLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        
        
        self.itemSize = CGSize(width: 96, height: 64)
        self.minimumLineSpacing = 16
        self.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        self.headerReferenceSize = CGSize.zero
        self.scrollDirection = .Horizontal 

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

