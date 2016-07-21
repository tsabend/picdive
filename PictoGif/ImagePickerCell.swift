//
//  ImagePickerCell.swift
//  picdive
//
//  Created by Thomas Abend on 4/23/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.imageView.contentMode = .ScaleAspectFill
        self.clipsToBounds = true
        self.contentView.addSubview(self.imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.contentView.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is terrible")
    }
    
    override var selected: Bool {
        didSet {
            if self.selected {
                self.layer.borderColor = UIColor.redColor().CGColor
                self.layer.borderWidth = 3
            } else {
                self.layer.borderColor = nil
                self.layer.borderWidth = 0
            }
        }
    }
}