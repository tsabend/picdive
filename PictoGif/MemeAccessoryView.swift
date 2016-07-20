//
//  MemeAccessoryView.swift
//  PictoGif
//
//  Created by Thomas Abend on 7/20/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit


@objc enum MemePosition: Int {
    case Top, Bottom
}

@objc protocol MemeAccessoryViewDelegate: class {
    func textFieldDidSwitch(toPosition positon: MemePosition)
    func allFinalWasToggled()
}

class MemeAccessoryView: UIView {
    var overAll : Bool {
        return self.allFinalToggle.selectedSegmentIndex == 0
    }
    private let allFinalToggle = UISegmentedControl()
    private let topBottomToggle = UISegmentedControl()
    
    var delegate : MemeAccessoryViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
        
        self.topBottomToggle.insertSegmentWithTitle("Top", atIndex: 0, animated: false)
        self.topBottomToggle.insertSegmentWithTitle("Bottom", atIndex: 1, animated: false)
        self.topBottomToggle.tintColor = UIColor.PDBlue()
        self.topBottomToggle.selectedSegmentIndex = 0
        
        self.allFinalToggle.insertSegmentWithTitle("Over All", atIndex: 0, animated: false)
        self.allFinalToggle.insertSegmentWithTitle("Over Last", atIndex: 1, animated: false)
        self.allFinalToggle.tintColor = UIColor.PDBlue()
        self.allFinalToggle.selectedSegmentIndex = 0
        
        self.topBottomToggle.addTarget(self, action: #selector(MemeAccessoryView.toggle), forControlEvents: .ValueChanged)
        
        self.allFinalToggle.addTarget(self, action: #selector(MemeAccessoryView.allFinalWasToggled), forControlEvents: .ValueChanged)
        
        //        self.addSubview(self.topBottomToggle)
        self.addSubview(self.allFinalToggle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.topBottomToggle.sizeToFit()
        self.topBottomToggle.moveToVerticalCenterOfSuperview()
        self.topBottomToggle.x = 8
        
        self.allFinalToggle.sizeToFit()
        self.allFinalToggle.moveToVerticalCenterOfSuperview()
        self.allFinalToggle.alignRight(8, toView: self)
        
    }
    
    func allFinalWasToggled() {
        self.delegate?.allFinalWasToggled()
    }
    
    func toggle() {
        if self.topBottomToggle.selectedSegmentIndex == 0 {
            self.delegate?.textFieldDidSwitch(toPosition: .Top)
        } else {
            self.delegate?.textFieldDidSwitch(toPosition: .Bottom)
        }
    }
}

