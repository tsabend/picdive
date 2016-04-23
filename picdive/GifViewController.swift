//
//  GifViewController.swift
//  picdive
//
//  Created by Sean on 3/6/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit


class GifViewController: PicDiveModalViewController {
    
    var gif: UIImage? {
        didSet {
            self.gifView.image = gif
        }
    }
    
    private let gifView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.view.addSubview(self.gifView)
        
    }
    
    override func share() {
        if let image = self.gif {
            let shareItems: Array = [image]
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.gifView.width = self.view.width
        self.gifView.height = self.view.width
        
        self.shareButton.moveBelow(siblingView: self.gifView, margin: 110, alignment: .Center)
        
    }
    
}