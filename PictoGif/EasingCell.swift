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
            self.setNeedsLayout()
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
    private let spinner = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.label.textColor = UIColor.whiteColor()
        self.label.font = UIFont.PDFont(withSize: 14)
        self.label.textAlignment = .Center
        self.container.layer.cornerRadius = 4
        self.imageView.layer.cornerRadius = 4
        self.container.backgroundColor = UIColor.PDGray()
        self.container.clipsToBounds = true
        self.imageView.clipsToBounds = true
        self.imageView.tintColor = UIColor.whiteColor()
        
        self.spinner.hidesWhenStopped = true
        
        self.contentView.addSubview(self.label)
        self.contentView.addSubview(self.container)
        self.container.addSubview(self.imageView)
        self.container.addSubview(self.spinner)
    }
    
    override var selected: Bool {
        didSet {
            self.imageView.tintColor = selected ? UIColor.PictoPink() : UIColor.whiteColor()
            if !selected {
                self.stopAnimating()
            }
        }
    }
    
    func startAnimating() {
        self.imageView.hidden = true
        self.spinner.startAnimating()
    }
    
    func stopAnimating() {
        self.imageView.hidden = false
        self.spinner.stopAnimating()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.container.origin = CGPoint.zero
        self.container.size = CGSize(self.width, self.height - 32)
        self.imageView.size = CGSize(100, 40)
        self.imageView.moveToCenterOfSuperview()
        self.spinner.moveToCenterOfSuperview()
        
        self.label.width = self.container.width
        self.label.sizeToFit()
        self.label.moveBelow(siblingView: self.container, margin: 8, alignment: .Center)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
