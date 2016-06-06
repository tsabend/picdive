//
//  EasingCell.swift
//  picdive
//
//  Created by Thomas Abend on 5/30/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

class EasingCell: UICollectionViewCell {
    static let size = CGSize(width: 124, height: 80)
    let container = UIView()
    
    
    var text : String? {
        didSet {
            self.label.text = text?.uppercaseString
        }
    }
    
    var image : UIImage? {
        didSet {
            if let image = self.image {
                self.imageView.image = image.imageWithRenderingMode(.AlwaysTemplate)
            }
        }
    }
    
    private let imageView = UIImageView()
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.label.textColor = UIColor.whiteColor()
        self.label.font = UIFont.PDFont(withSize: 14)
        self.container.layer.cornerRadius = 4
        self.imageView.layer.cornerRadius = 4
        self.container.backgroundColor = UIColor.PDGray()
        self.container.clipsToBounds = true
        self.imageView.clipsToBounds = true
        self.imageView.tintColor = UIColor.whiteColor()
        self.contentView.addSubview(self.label)
        self.contentView.addSubview(self.container)
        self.container.addSubview(self.imageView)
    }
    
    override var selected: Bool {
        didSet {
//            self.label.textColor = self.selected ? UIColor.PDBlue() : UIColor.whiteColor()
//            self.container.backgroundColor = selected ? UIColor.PDDarkGray().colorWithAlphaComponent(0.66) : UIColor.PDGray()
            self.imageView.tintColor = selected ? UIColor.PictoPink() : UIColor.whiteColor()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.container.origin = CGPoint.zero
        self.container.size = CGSize(self.width, self.height - 32)
        self.imageView.size = CGSize(100, 40)
        self.imageView.moveToCenterOfSuperview()
        
        self.label.sizeToFit()
        self.label.moveBelow(siblingView: self.container, margin: 8, alignment: .Center)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
