//
//  EasingViewController.swift
//  picdive
//
//  Created by Thomas Abend on 5/8/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit
protocol EasingType {
    var label: String { get }
}

enum ScopeEasing: EasingType {
    case In, Out, Linear
    var label: String {
        switch self {
        case In:
            return "In"
        case Out:
            return "Out"
        case Linear:
            return "Linear"
        }
    }
}

class EasingCell: UICollectionViewCell {
    let imageView = UIImageView()
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.PDLightGray()
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.label)
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.label.sizeToFit()
        self.label.moveToCenterOfSuperview()
    }
}

class EasingViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var collectionView: UICollectionView!
    var easings: [EasingType] = []
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
            cell.label.text = easing.label
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("boom")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionView.frame = self.view.bounds
        self.collectionView.contentSize = self.view.bounds.size
        self.collectionView.contentOffset = CGPoint.zero

    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        super.didMoveToParentViewController(parent)
//        self.collectionView.contentOffset = CGPoint.zero
//        self.automaticallyAdjustsScrollViewInsets = false
//        self.edgesForExtendedLayout = UIRectEdge.None
        self.collectionView.contentInset = UIEdgeInsetsZero
        self.collectionView.invalidateIntrinsicContentSize()
        
        self.collectionView.reloadData()

    }
}

class EasingFlowLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        
        
        self.itemSize = CGSize(width: 128, height: 64)
        self.minimumLineSpacing = 16
        self.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.headerReferenceSize = CGSize.zero
        self.scrollDirection = .Horizontal 

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

