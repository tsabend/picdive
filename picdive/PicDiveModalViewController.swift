//
//  PicDiveModalViewController.swift
//  picdive
//
//  Created by Sean on 3/6/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

class PicDiveModalViewController: UIViewController {

    let shareButton = UIButton()
    let backButton = UIButton()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.PDDarkGray()
        
        self.backButton.setTitle("↑", forState: .Normal)
    
        self.backButton.setTitleColor(UIColor.PDLightGray(), forState: .Normal)
        self.backButton.addTarget(self, action: #selector(PicDiveModalViewController.dismiss), forControlEvents: .TouchUpInside)
        self.backButton.backgroundColor = UIColor.PDTeal()
        
        self.shareButton.setTitle("Share", forState: .Normal)
        self.shareButton.setTitleColor(UIColor.PDLightGray(), forState: .Normal)
        self.shareButton.addTarget(self, action: #selector(PicDiveModalViewController.share), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(self.shareButton)
        self.view.addSubview(self.backButton)
        
    }
    
    func share() {
        // NO OP
        // implement in subclass
    }
    
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.backButton.width = self.view.width
        self.backButton.height = 60
        self.backButton.y = UIApplication.sharedApplication().statusBarFrame.height
        
        self.shareButton.sizeToFit()

    }

    
}