//
//  EasingViewController.swift
//  picdive
//
//  Created by Thomas Abend on 5/8/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

class EasingViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var collectionView: UICollectionView!
    var easings: [EasingType] = []
    var onClick: ((EasingType?, (Void -> Void)?) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()

        let flowLayout = EasingFlowLayout()
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.collectionView.registerClass(EasingCell.self, forCellWithReuseIdentifier: String(EasingCell.self))
        self.collectionView.backgroundColor = UIColor.clearColor()
        self.collectionView.showsHorizontalScrollIndicator = false
        
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
            cell.text = easing.text
            cell.image = easing.image
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.collectionView.userInteractionEnabled = false
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! EasingCell
        cell.startAnimating()
        
        
        self.onClick?(self.easings[safe: indexPath.row]) {
                let cell = collectionView.cellForItemAtIndexPath(indexPath) as! EasingCell
                cell.stopAnimating()
                self.collectionView.userInteractionEnabled = true
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? EasingCell {
            UIView.animateWithDuration(0.1, animations: {
                cell.transform = CGAffineTransformMakeScale(0.96, 0.96)
            })
        }
        return true
    }
    
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? EasingCell {
            UIView.animateWithDuration(0.2, animations: {
                cell.transform = CGAffineTransformIdentity
            })
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionView.frame = self.view.bounds
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        super.didMoveToParentViewController(parent)
        self.collectionView.reloadData()
        after(seconds: 0.1) {
            self.collectionView.selectItemAtIndexPath(NSIndexPath(forItem: 0,inSection: 0), animated: false, scrollPosition: .None)
        }
    }
}
