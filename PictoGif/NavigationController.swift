//
//  NavigationController.swift
//  picdive
//
//  Created by Thomas Abend on 4/26/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barTintColor = UIColor.PDDarkGray()
        self.navigationBar.tintColor = UIColor.PDLightGray()
        self.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.PDLightGray(),
            NSFontAttributeName: UIFont.PDFont(withSize: 21)
        ]
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}