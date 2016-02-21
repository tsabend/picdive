//
//  UIView+Helpers.swift
//  picdive
//
//  Created by Thomas Abend on 2/20/16.
//  Copyright © 2016 Sean. All rights reserved.
//
import UIKit

extension UIView {
    
    var size: CGSize {
        get { return self.frame.size }
        set { self.frame.size = newValue }

    }
    var width: CGFloat {
        get { return self.size.width }
        set { self.size.width = newValue }
    }
    
    var height: CGFloat {
        get { return self.size.height }
        set { self.size.height = newValue }
    }
    
}

extension Int {
    var f: CGFloat {
        return CGFloat(self)
    }
}

