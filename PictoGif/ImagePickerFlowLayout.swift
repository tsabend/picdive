//
//  ImagePickerFlowLayout.swift
//  PictoGif
//
//  Created by Thomas Abend on 7/8/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

class ImagePickerFlowLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        
        let interItemSpacing: CGFloat = 1
        self.minimumInteritemSpacing = interItemSpacing
        self.minimumLineSpacing = interItemSpacing
        let itemSideLength = (UIScreen.mainScreen().bounds.width / 4) - interItemSpacing
        self.itemSize = CGSize(width: itemSideLength, height: itemSideLength)
        self.sectionInset = UIEdgeInsets(top: 1, left: 0, bottom: itemSideLength * 2, right: 0)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("coder")
    }
    
}
