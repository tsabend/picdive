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
    
    private func easeIn(framesCount: Int, totalTime c: Double) -> [Double] {
        let d = Double(framesCount)
        let b = c * d / 100
        return (0..<framesCount).map { (t) -> Double in
            let factor = pow(Double(t)/d, 2)
            return b + (c-b) * factor
        }
    }
}

enum TimingEasing: EasingType {
    case Linear, FinalFrame, Reverse
    var label: String {
        switch self {
        case Linear:
            return "Linear"
        case FinalFrame:
            return "Final Frame"
        case Reverse:
            return "Reverse"
        }
    }
    
//    private func easeIn(framesCount: Int, totalTime c: Double) -> [Double] {
//        let d = Double(framesCount)
//        let b = c * d / 100
//        return (0..<framesCount).map { (t) -> Double in
//            let factor = pow(Double(t)/d, 2)
//            return b + (c-b) * factor
//        }
//    }
//    private func easeIn(framesCount: Int, totalTime c: Double) -> [Double] {
//        let min = 1.0
//        let weightings = (0..<framesCount).map { (t) -> Double in
//            let factor = pow(t.d/c, 2)
//            return factor * (framesCount.d - t.d) + min
//        }
//        let divisor = weightings.reduce(0, combine: +)
//        return weightings.map({c*$0/divisor})
//    }

    
    func times(framesCount count: Int, totalTime duration: Double) -> [Double] {
        switch self {
        case .Linear, .Reverse:
            return (0..<count).map {_ in duration/count.d}
        case .FinalFrame:
            var norms = (0..<count-1).map {_ in 2.d/3.d*duration/count.d}
            let final = 2.d/3.d*duration/count.d + 1.0/3.0
            norms.append(<#T##newElement: Element##Element#>)
            
            // 0.5, 0.5, 0.75, 1.5
            
            let last = norm * 3/count.d

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
        self.collectionView.frame = self.view.bounds
        self.collectionView.contentSize = self.view.bounds.size
        self.collectionView.contentOffset = CGPoint.zero

    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        super.didMoveToParentViewController(parent)
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

