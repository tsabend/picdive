//
//  GifViewController.swift
//  picdive
//
//  Created by Sean on 3/6/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

class GifViewController: UIViewController {
    
    var gif: UIImage? {
        didSet {
            self.gifView.image = gif
        }
    }
    
    private let gifView = UIImageView()
    private let shareButton = UIButton()
    private let backButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.PDOrange()
        
        self.backButton.setTitle("↑", forState: .Normal)
        self.backButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.backButton.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
        self.backButton.backgroundColor = UIColor.PDPurple()
        
        self.shareButton.setTitle("Share", forState: .Normal)
        self.shareButton.setTitleColor(UIColor.PDPurple(), forState: .Normal)
        self.shareButton.addTarget(self, action: "share", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(self.gifView)
        self.view.addSubview(self.shareButton)
        self.view.addSubview(self.backButton)
        
    }
    
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func share() {
        if let image = self.gif {
            let shareItems: Array = [image]
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.backButton.width = self.view.width
        self.backButton.height = 60
        
        self.gifView.width = self.view.width
        self.gifView.height = self.view.width
        self.gifView.moveBelow(siblingView: self.backButton, margin: 0)
        
        self.shareButton.sizeToFit()
        self.shareButton.moveBelow(siblingView: self.gifView, margin: 110, alignment: .Center)
        
    }
    
}