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
        UIView.animateWithDuration(0.2, animations: {
            self.alpha = 0.95
            }, completion: { (_) in
                UIView.animateWithDuration(0.2, animations: {
                    self.alpha = 0
                })
        })

    }
    
}