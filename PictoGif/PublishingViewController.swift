//
//  PublishingViewController.swift
//  picdive
//
//  Created by Thomas Abend on 4/26/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import AVKit
import AVFoundation
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
    private let videoButton = SubtitledButton()
    private let gifButton = SubtitledButton()
    private let stripButton = SubtitledButton()
    private let stripView = UIScrollView()
    private let stripImageView = UIImageView()
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .White)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Share"
        self.setupNavigationBar()
        
        self.view.backgroundColor = UIColor.PDDarkGray()

        self.setupButton(self.videoButton, title: "Video", selector: #selector(PublishingViewController.shareVideo))
        self.setupButton(self.gifButton, title: "Gif", selector: #selector(PublishingViewController.shareGif))
        self.setupButton(self.stripButton, title: "Photo Strip", selector: #selector(PublishingViewController.shareStrip))
        
        self.spinner.hidesWhenStopped = true
        self.view.addSubview(self.spinner)
        
        self.view.addSubview(self.gifView)
        self.stripView.addSubview(self.stripImageView)
        self.view.addSubview(self.stripView)
    }
    
    private func setupButton(button: UIButton, title: String, selector: Selector) {
        button.setTitle(title, forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.font = UIFont.PDFont(withSize: 18)
        button.setImage(UIImage(named: "share")?.resized(toSize: CGSize(28, 28)), forState: .Normal)
        button.addTarget(self, action: selector, forControlEvents: .TouchUpInside)
        self.view.addSubview(button)
    }
    
    func setupNavigationBar() {
        
        let barButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self.navigationController, action: #selector(UINavigationController.popToRootViewControllerAnimated(_:)))
        let backButton = BarButtonItem(image: BarButtonItem.backImage) { [weak self] in
            self?.back()
        }
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func back() {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    func shareGif() {
        guard let gif = self.imageViewDataSource as? Gif else { return }
        self.share(gif.data)
    }
    
    private var cachedVideoURL: NSURL?
    func shareVideo() {
        guard let gif = self.imageViewDataSource as? Gif else { return }
        
        if let url = self.cachedVideoURL {
          self.share(url)
        } else {
            self.spinner.center = self.videoButton.center
            self.videoButton.hidden = true
            self.spinner.startAnimating()
            gif.asVideo { (url) in
                if let url = url {
                    self.cachedVideoURL = url
                    self.spinner.stopAnimating()
                    self.videoButton.hidden = false
                    self.share(url)
                }
            }
            
        }
    }
    
    func shareStrip() {
        guard let gif = self.imageViewDataSource as? Gif, strip = gif.horizontalStrip else { return }
        self.share(strip)
    }
    
    func share(object: AnyObject) {
        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [object], applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.gifView.size = CGSize(Config.imageViewWidth, Config.imageViewWidth)
        self.gifView.moveToHorizontalCenterOfSuperview()
        self.gifView.y = self.navigationController?.navigationBar.maxY ?? 0
        
        self.gifButton.sizeToFit()
        self.stripButton.sizeToFit()
        self.videoButton.sizeToFit()
        
        self.gifButton.moveBelow(siblingView: self.gifView, margin: 8, alignment: .Center)
        let buttonSpacing: CGFloat = 64
        self.gifButton.x -= (buttonSpacing + self.gifButton.width) / 2
        self.videoButton.moveRight(siblingView: self.gifButton, margin: 64, alignVertically: true)
        
        let stripHeight = self.view.height * 0.09
        self.stripView.width = self.view.width
        self.stripView.height = stripHeight
        self.stripImageView.size.height = stripHeight
        self.stripImageView.size.width = stripHeight * (self.imageViewDataSource as! Gif).images.count.f
        self.stripView.contentSize.width = self.stripImageView.width
        if self.stripImageView.width < self.view.width {
            self.stripImageView.moveToCenterOfSuperview()
        }
        
        self.stripView.moveBelow(siblingView: self.gifButton, margin: 8)
        self.stripButton.moveBelow(siblingView: self.stripView, margin: 8, alignment: .Center)
        
        self.spinner.sizeToFit()
    }
}
