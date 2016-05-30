//
//  EasingCell.swift
//  picdive
//
//  Created by Thomas Abend on 5/30/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

class EasingCell: UICollectionViewCell {
    let imageView = UIImageView()
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.label.textColor = UIColor.PDBlue()
        self.contentView.backgroundColor = UIColor.PDGray()
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.label)
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 2
    }
    
    override var selected: Bool {
        didSet {
            self.label.textColor = self.selected ? UIColor.yellowColor() : UIColor.PDBlue()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.label.sizeToFit()
        self.label.moveToCenterOfSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
