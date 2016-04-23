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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is terrible")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.contentView.bounds
    }
    
}

