//
//  EasingCell.swift
//  picdive
//
//  Created by Thomas Abend on 5/30/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

class EasingCell: UICollectionViewCell {
    static let size = CGSize(width: 108, height: 72)
    let container = UIView()
    let imageView = UIImageView()
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.label.textColor = UIColor.PDBlue()
        
        self.container.layer.cornerRadius = 4
        self.imageView.layer.cornerRadius = 4
        self.container.backgroundColor = UIColor.PDGray()
        self.container.clipsToBounds = true
        self.imageView.clipsToBounds = true
        
        self.contentView.addSubview(self.label)
        self.contentView.addSubview(self.container)
        self.container.addSubview(self.imageView)
    }
    
    override var selected: Bool {
        didSet {
            self.label.textColor = self.selected ? UIColor.yellowColor() : UIColor.PDBlue()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.container.origin = CGPoint.zero
        self.container.size = CGSize(self.width, self.height - 32)
        self.imageView.size = CGSize(100, 40)
        self.imageView.moveToHorizontalCenterOfSuperview()
        
        self.label.sizeToFit()
        self.label.moveBelow(siblingView: self.container, margin: 8, alignment: .Center)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
