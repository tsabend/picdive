//
//  MemeAccessoryView.swift
//  PictoGif
//
//  Created by Thomas Abend on 7/20/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

@objc protocol MemeAccessoryViewDelegate: class {

    func allFinalWasToggled()
}

class MemeAccessoryView: UIView {
    var overAll : Bool {
        return self.allFinalToggle.selectedSegmentIndex == 0
    }
    private let allFinalToggle = UISegmentedControl()
    
    var delegate : MemeAccessoryViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
        
        self.allFinalToggle.insertSegmentWithTitle("Over All", atIndex: 0, animated: false)
        self.allFinalToggle.insertSegmentWithTitle("Over Last", atIndex: 1, animated: false)
        self.allFinalToggle.tintColor = UIColor.PDBlue()
        self.allFinalToggle.selectedSegmentIndex = 0

        self.allFinalToggle.addTarget(self, action: #selector(MemeAccessoryView.allFinalWasToggled), forControlEvents: .ValueChanged)
        
        self.addSubview(self.allFinalToggle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.allFinalToggle.sizeToFit()
        self.allFinalToggle.moveToVerticalCenterOfSuperview()
        self.allFinalToggle.x = 8
    }
    
    func allFinalWasToggled() {
        self.delegate?.allFinalWasToggled()
    }
    
}

