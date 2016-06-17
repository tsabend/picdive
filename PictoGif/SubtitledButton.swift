//
//  SubtitledButton.swift
//  picdive
//
//  Created by Thomas Abend on 6/6/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit
class SubtitledButton : UIButton {
    
    override var highlighted: Bool {
        didSet {
            self.titleLabel?.textColor = highlighted ? self.titleLabel?.textColor.colorWithAlphaComponent(0.5) : self.titleLabel?.textColor
        }
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        guard let titleLabel = self.titleLabel, imageView = self.imageView else { return super.sizeThatFits(size) }
        let labelSize = titleLabel.sizeThatFits(size)
        let imageViewSize = imageView.sizeThatFits(size)
        let width = max(max(labelSize.width, imageViewSize.width), 44)
        let height =  max((labelSize.height + imageViewSize.height + 16), 44)
        return CGSize(width, height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.sizeToFit()
        self.titleLabel?.sizeToFit()
        self.imageView?.y = 0
        self.imageView?.moveToHorizontalCenterOfSuperview()
        self.titleLabel?.moveBelow(siblingView: self.imageView ?? self, margin: 16, alignment: .Center)
    }
}
