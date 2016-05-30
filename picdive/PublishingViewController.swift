//
//  PublishingViewController.swift
//  picdive
//
//  Created by Thomas Abend on 4/26/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

class PublishingViewController : UIViewController, ImagePresenter {
    
    var imageViewDataSource: ImageViewDataSource? {
        didSet {
            if let gif = self.imageViewDataSource as? Gif {
                self.gifView.image = gif.image
                self.stripImageView.image = gif.horizontalStrip
            }
        }
    }

    private let gifView = UIImageView()
    private let shareButton = UIButton()
    private let gifButton = UIButton()
    private let stripButton = UIButton()
    private let stripView = UIScrollView()
    private let stripImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Share"
        self.setupNavigationBar()
        
        self.view.backgroundColor = UIColor.PDDarkGray()

        self.gifButton.setTitle("Copy as Gif", forState: .Normal)
        self.gifButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.gifButton.addTarget(self, action: #selector(PublishingViewController.copyGif), forControlEvents: .TouchUpInside)
        
        self.stripButton.setTitle("Copy as Photo Strip", forState: .Normal)
        self.stripButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.stripButton.addTarget(self, action: #selector(PublishingViewController.copyStrip), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(self.shareButton)
        self.view.addSubview(self.gifButton)
        self.view.addSubview(self.stripButton)
        self.view.addSubview(self.gifView)
        self.stripView.addSubview(self.stripImageView)
        self.view.addSubview(self.stripView)
    }
    
    func setupNavigationBar() {
        let barButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self.navigationController, action: #selector(UINavigationController.popToRootViewControllerAnimated(_:)))
        let backButton = UIBarButtonItem(title: "X", style: UIBarButtonItemStyle.Done, target: self, action: #selector(PublishingViewController.back))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func back() {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    func copyGif() {
        guard let gif = self.imageViewDataSource as? Gif else { return }
        UIPasteboard.generalPasteboard().setData(gif.data, forPasteboardType: "com.compuserve.gif")
        self.presentCopyConfirm()
    }
    
    func copyStrip() {
        guard let gif = self.imageViewDataSource as? Gif else { return }
        let strip = UIImage.stitchImagesVertical(gif.images)
        UIPasteboard.generalPasteboard().image = strip
        self.presentCopyConfirm()
    }

    private func presentCopyConfirm(){
        let vc = UIAlertController(title: "Copied!", message: nil, preferredStyle: .Alert)
        vc.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.gifView.size = CGSize(self.view.width, self.view.width)
        self.gifView.y = self.navigationController?.navigationBar.maxY ?? 0
        
        self.gifButton.sizeToFit()
        self.stripButton.sizeToFit()
        
        self.gifButton.moveBelow(siblingView: self.gifView, margin: 16, alignment: .Center)
        
        self.stripView.width = self.view.width
        self.stripView.height = 64
        self.stripImageView.size.height = 64
        self.stripImageView.size.width = 64 * (self.imageViewDataSource as! Gif).images.count.f
        self.stripView.contentSize.width = self.stripImageView.width
        if self.stripImageView.width < self.view.width {
            self.stripImageView.moveToCenterOfSuperview()
        }
        
        self.stripView.moveBelow(siblingView: self.gifButton, margin: 16)
        self.stripButton.moveBelow(siblingView: self.stripView, margin: 16, alignment: .Center)
    }
}
