//
//  NavigationController.swift
//  picdive
//
//  Created by Thomas Abend on 4/26/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

extension UINavigationController {
    func pushViewControllerWithTransitions(viewController: UIViewController, @noescape from: Void -> Void,  @noescape to: Void -> Void) {
        from()
        self.pushViewController(viewController, animated: false)
        to()
    }
}