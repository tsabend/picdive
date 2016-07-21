//
//  UIView+Animations.swift
//  picdive
//
//  Created by Thomas Abend on 5/30/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

extension UIView {
    
    func flash() {
        self.alpha = 1
        UIView.animateWithDuration(0.5) {
            self.alpha = 0
        }
    }
    
}