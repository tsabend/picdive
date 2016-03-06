//
//  ReelViewController.swift
//  picdive
//
//  Created by Sean on 3/6/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

class ReelViewController: PicDiveModalViewController {
    
    var reel: UIImage? {
        didSet {
            self.imageView.image = reel
        }
    }
    
    let imageView = UIImageView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.contentMode = .ScaleAspectFit
        self.view.addSubview(self.imageView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.imageView.sizeToFit()
        self.imageView.width = self.view.width / 2
        self.imageView.height = fmin(self.imageView.height, self.view.height)
        self.imageView.moveBelow(siblingView: self.backButton, margin: 0, alignment: .Left)
        
    }
}
