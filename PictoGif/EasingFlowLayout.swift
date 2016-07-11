//
//  EasingFlowLayout.swift
//  PictoGif
//
//  Created by Thomas Abend on 7/8/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

class EasingFlowLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        
        self.itemSize = EasingCell.size
        self.minimumLineSpacing = 16
        self.minimumInteritemSpacing = 8
        self.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        self.scrollDirection = .Horizontal
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

