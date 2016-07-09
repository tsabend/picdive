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
import Crashlytics

class PublishingViewController : UIViewController, ImagePresenter {
    
    var imageViewDataSource: ImageViewDataSource? {
        didSet {
            if let gif = self.imageViewDataSource as? Gif {
                self.gifView.image = gif.image
            }
        }
    }

    private let gifView = UIImageView()
    private let videoButton = SubtitledButton()
    private let gifButton = SubtitledButton()
    private let stripButton = SubtitledButton()
    private let instagramExplanationLabel = UILabel()
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .White)
    
    // MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Export and Share"
        self.setupNavigationBar()
        
        self.view.backgroundColor = UIColor.PDDarkGray()

        self.setupButton(self.videoButton, title: "Video", imageName: "movie_p", selector: #selector(PublishingViewController.shareVideo))
        self.setupButton(self.gifButton, title: "Gif", imageName: "frames_many", selector: #selector(PublishingViewController.shareGif))
        self.setupButton(self.stripButton, title: "Photo", imageName: "strip_p", selector: #selector(PublishingViewController.shareStrip))
        
        self.instagramExplanationLabel.text = "*Use videos for sharing on Instagram, since they do not animate gifs."
        self.instagramExplanationLabel.font = UIFont.PDFont(withSize: 12)
        self.instagramExplanationLabel.textColor = UIColor.whiteColor()
        self.instagramExplanationLabel.numberOfLines = 0
        
        self.spinner.hidesWhenStopped = true
        self.view.addSubview(self.spinner)
        self.view.addSubview(self.gifView)
        self.view.addSubview(self.instagramExplanationLabel)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.gifView.size = CGSize(Config.imageViewWidth, Config.imageViewWidth)
        self.gifView.moveToHorizontalCenterOfSuperview()
        self.gifView.y = self.navigationController?.navigationBar.maxY ?? 0
        
        self.gifButton.sizeToFit()
        self.stripButton.sizeToFit()
        self.videoButton.sizeToFit()
        
        let buttonSpacing: CGFloat = 64
        self.videoButton.moveBelow(siblingView: self.gifView, margin: buttonSpacing, alignment: .Center)
        self.gifButton.moveLeft(siblingView: self.videoButton, margin: buttonSpacing, alignVertically: true)
        self.stripButton.moveRight(siblingView: self.videoButton, margin: buttonSpacing, alignVertically: true)
        
        self.spinner.sizeToFit()
        
        self.instagramExplanationLabel.sizeToFit()
        self.instagramExplanationLabel.width = self.view.width - 32
        self.instagramExplanationLabel.moveToHorizontalCenterOfSuperview()
        self.instagramExplanationLabel.alignBottom(8, toView: self.view)
    }
    
    private func setupButton(button: UIButton, title: String, imageName: String, selector: Selector) {
        button.setTitle(title, forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.font = UIFont.PDFont(withSize: 18)
        
        button.imageView?.tintColor = UIColor.PictoPink()
        button.setImage(UIImage(named: imageName)?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
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
    
    
    // MARK: - Sharing
    func shareGif() {
        guard let data = (self.imageViewDataSource as? Gif)?.data else { return }
        Answers.logCustomEventWithName("Share began",
                                       customAttributes: ["withType": "gif"])
        self.share(data)
    }
    
    func shareStrip() {
        Answers.logCustomEventWithName("Share began",
                                       customAttributes: ["withType": "strip"])
        guard let gif = self.imageViewDataSource as? Gif, strip = gif.verticalStrip else { return }
        self.share(strip)
    }
    
    private var cachedVideoURL: NSURL?
    func shareVideo() {
        guard let gif = self.imageViewDataSource as? Gif else { return }
        Answers.logCustomEventWithName("Share began",
                                       customAttributes: ["withType": "video"])
        
        if let url = self.cachedVideoURL {
          self.share(url)
        } else {
            self.spinner.center = self.videoButton.center
            self.videoButton.hidden = true
            self.spinner.startAnimating()
            gif.asVideo { (result: Result<NSURL?>) -> Void in
                immediately {
                    self.spinner.stopAnimating()
                    self.videoButton.hidden = false
                }
                
                do {
                    if let url = try result.unwrap() {
                        
                        self.cachedVideoURL = url
                        self.share(url)
                    }
                } catch {
                    immediately {
                        self.showError(message: "Looks like something went wrong under the hood...try that again.")
                    }
                }
            }
        }
    }

    func showError(message message: String) {
        let vc = UIAlertController(title: "Yikes", message: message, preferredStyle: .Alert)
        vc.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func share(object: AnyObject) {
        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [object], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { [weak self] (activityType: String?, _, _, _) -> Void in
            guard let gif = self?.imageViewDataSource as? Gif else { return }
            if let type = activityType {
                var attrs = gif.analyticsDictionary
                attrs += ["to platform": type]
                Answers.logCustomEventWithName("Share succeeded",
                                               customAttributes: attrs)
            } else {
                Answers.logCustomEventWithName("Share cancelled",
                                               customAttributes: [:])
            }
        }
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }

}

