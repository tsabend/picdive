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
            }
        }
    }

    private let gifView = UIImageView()
    private let shareButton = UIButton()
    private let gifButton = UIButton()
    private let stripButton = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.PDDarkGray()

        self.navigationItem.title = "Share"
        self.setupNavigationBar()
        self.view.addSubview(self.gifView)
    }
    
    func setupNavigationBar() {
        let barButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self.navigationController, action: #selector(UINavigationController.popToRootViewControllerAnimated(_:)))
        let backButton = UIBarButtonItem(title: "X", style: UIBarButtonItemStyle.Done, target: self.navigationController, action: #selector(PublishingViewController.back))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.rightBarButtonItem = barButton
        
        self.shareButton.setTitle("Share Gif", forState: .Normal)
        self.shareButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.shareButton.addTarget(self, action: #selector(PublishingViewController.share), forControlEvents: .TouchUpInside)
        self.gifButton.setTitle("Copy Gif", forState: .Normal)
        self.gifButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.gifButton.addTarget(self, action: #selector(PublishingViewController.copyGif), forControlEvents: .TouchUpInside)
        
        self.stripButton.setTitle("Copy Strip", forState: .Normal)
        self.stripButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.stripButton.addTarget(self, action: #selector(PublishingViewController.copyStrip), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(self.shareButton)
        self.view.addSubview(self.gifButton)
        self.view.addSubview(self.stripButton)
    }
    
    func back() {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    func copyGif() {
        guard let gif = self.imageViewDataSource as? Gif else { return }
        UIPasteboard.generalPasteboard().setData(gif.data, forPasteboardType: "com.compuserve.gif")
        self.presentCopyConfirm()
    }
    
    func presentCopyConfirm(){
        let vc = UIAlertController(title: "Copied!", message: nil, preferredStyle: .Alert)
        vc.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func copyStrip() {
        guard let gif = self.imageViewDataSource as? Gif else { return }
        let strip = UIImage.stitchImages(gif.images)
        UIPasteboard.generalPasteboard().image = strip
        self.presentCopyConfirm()
    }
    
    func share() {
        guard let gif = self.imageViewDataSource as? Gif, strip = UIImage.stitchImages(gif.images) else { return }
        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [strip], applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.gifView.size = CGSize(self.view.width, self.view.width)
        self.gifView.center = self.view.center
        
        self.shareButton.sizeToFit()
        self.shareButton.moveBelow(siblingView: self.gifView, margin: 44, alignment: .Center)
        
        self.gifButton.sizeToFit()
        self.stripButton.sizeToFit()
        
        let xMargin = (self.view.width - self.gifButton.width - self.stripButton.width) / 3
        self.gifButton.moveAbove(siblingView: self.gifView, margin: 22)
        self.gifButton.x = xMargin
        self.stripButton.moveRight(siblingView: self.gifButton, margin: xMargin, alignVertically: true)
    }
}
