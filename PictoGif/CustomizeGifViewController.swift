//
//  CustomizeGifViewController.swift
//  picdive
//
//  Created by Thomas Abend on 4/26/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit
import ASValueTrackingSlider

class CustomizeGifViewController: UIViewController, FlowViewController, ImagePresenter, ASValueTrackingSliderDataSource {
    typealias Next = PublishingViewController
    var imageViewDataSource: ImageViewDataSource? {
        didSet {
            if let gif = self.gif {
                self.gifView.image = gif.image
            }
        }
    }
    var gif: Gif? {
        get { return self.imageViewDataSource as? Gif }
        set { self.imageViewDataSource = newValue }
    }

    private let gifView = UIImageView()
    let easingsViewController = EasingViewController()
    let slider = Slider()
    private let watermarkButton = UIButton()
    var easing = TimingEasing.FinalFrame
    private let flash = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false

        self.title = "Customize your Gif"
        self.setupNavigationBar()
        
        self.slider.addTarget(self, action: #selector(CustomizeGifViewController.sliderDidSlide(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.slider.continuous = false
        self.slider.minimumTrackTintColor = UIColor.PictoPink()
        
        self.slider.setupValues(min: 2, max: 10, initial: 8)
        self.slider.setupImages(min: UIImage(named: "time_slow"), max: UIImage(named: "time_fast"))
        self.slider.dataSource = self
        
        self.easingsViewController.easings = [TimingEasing.FinalFrame,  TimingEasing.Linear, TimingEasing.Reverse, TimingEasing.ReverseFinalFrame]
        
        self.addChildViewController(self.easingsViewController)
        self.view.addSubview(self.easingsViewController.view)
        self.easingsViewController.didMoveToParentViewController(self)
       
        self.easingsViewController.onClick = { [weak self] easing in
            if let easing = easing as? TimingEasing {
                self?.easing = easing
            }
            self?.setGif()
        }
        
        self.flash.backgroundColor = UIColor.whiteColor()
        self.flash.alpha = 0
        
        self.watermarkButton.addTarget(self, action: #selector(CustomizeGifViewController.buyRemoveWatermark), forControlEvents: .TouchUpInside)
        self.watermarkButton.setTitle("REMOVE WATERMARK", forState: .Normal)
        self.watermarkButton.titleLabel?.font = UIFont.PDFont(withSize: 14)
        self.watermarkButton.backgroundColor = UIColor.PictoPink()
        self.watermarkButton.hidden = PicDiveProducts.hasPurchasedWatermark
        self.view.backgroundColor = UIColor.PDDarkGray()
        self.view.addSubview(self.gifView)
        self.view.addSubview(self.slider)
        self.gifView.addSubview(self.flash)
        self.view.addSubview(self.watermarkButton)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomizeGifViewController.removeWatermark), name: IAPHelper.IAPHelperPurchaseNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomizeGifViewController.reportFailure), name: IAPHelper.IAPHelperPurchaseFailedNotification, object: nil)
        
    }
    
    func animateIn() {
        self.easingsViewController.view.alpha = 0
        UIView.animateWithDuration(0.2) {
            self.easingsViewController.view.alpha = 1
        }
    }
    
    func sliderDidSlide(slider: UISlider) {
        self.setGif()
    }
    
    func slider(slider: ASValueTrackingSlider!, stringForValue value: Float) -> String! {
        return "\(self.translatedSliderValue.format(".2")) seconds"
    }
    
    private var translatedSliderValue: Float {
        return 12.0 - self.slider.value
    }
    
    func setGif() {
        guard let gif = self.gif else { return }
        self.flash.flash()
        self.gif = Gif(images: gif.images, easing: self.easing, totalTime: Double(self.translatedSliderValue))
    }
    
    func removeWatermark() {
        self.setGif()
        self.watermarkButton.hidden = true
    }
    
    func reportFailure(notification: NSNotification) {
        let message = notification.object as? String ?? "The purchase failed. Check your connection or try again later."
        let vc = UIAlertController(title: "Womp", message: message, preferredStyle: .Alert)
        vc.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.gifView.size = CGSize(Config.imageViewWidth, Config.imageViewWidth)
        self.gifView.moveToHorizontalCenterOfSuperview()
        
        self.gifView.y = self.navigationController?.navigationBar.maxY ?? 0
        self.flash.frame = self.gifView.bounds
        
        self.slider.sizeToFit()
        self.slider.width = self.view.width - 22
        self.slider.moveBelow(siblingView: self.gifView, margin: Config.baseMargin * 2, alignment: .Center)

        self.easingsViewController.view.size = CGSize(width: self.gifView.width, height: 100)
        self.easingsViewController.view.moveBelow(siblingView: self.slider, margin: Config.baseMargin, alignment: .Center)
        
        self.watermarkButton.size = CGSize(self.view.width, 32)
        self.watermarkButton.alignBottom(0, toView: self.view)
        
    }
    
    func buyRemoveWatermark() {
        let vc = UIAlertController(title: "Remove watermark", message: "Tired of seeing our logo on your PictoGifs? Pay once and remove it forever.", preferredStyle: .Alert)
        vc.addAction(UIAlertAction(title: "🙌 Yaaaaas 🙌", style: .Default) { (_) in
            PicDiveProducts.store.buyProduct(withIdentifier: PicDiveProducts.RemoveWatermark)
        })
        
        vc.addAction(UIAlertAction(title: "Restore Previous Purchase", style: .Default) { (_) in
            PicDiveProducts.store.restorePurchases()
            })
        
        vc.addAction(UIAlertAction(title: "Not now", style: .Cancel, handler: { _ in NSUserDefaults.standardUserDefaults().setBool(false, forKey: "hasPaid")
            self.setGif()
        }))
        
        self.presentViewController(vc, animated: true, completion: nil)
    }

}
