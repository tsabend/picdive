//
//  CustomizeGifViewController.swift
//  picdive
//
//  Created by Thomas Abend on 4/26/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit
import pop

class CustomizeGifViewController: UIViewController, FlowViewController, ImagePresenter {
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
    var easing = TimingEasing.Linear
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Customize your Gif"
        self.setupNavigationBar()
        
        self.slider.addTarget(self, action: #selector(CustomizeGifViewController.sliderDidSlide(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.slider.continuous = false
        
        self.slider.setupValues(min: 2, max: 10, initial: Float(self.gif?.images.count ?? 4))
        self.slider.setupImages(min: UIImage(named: "few-frames"), max: UIImage(named: "many-frames"))
        
        self.easingsViewController.label.text = "Timing"
        self.addChildViewController(self.easingsViewController)
        self.view.addSubview(self.easingsViewController.view)
        self.easingsViewController.didMoveToParentViewController(self)
        self.easingsViewController.easings = [TimingEasing.Linear,  TimingEasing.FinalFrame, TimingEasing.Reverse, TimingEasing.ReverseFinalFrame]
        self.easingsViewController.onClick = { [weak self] easing in
            guard let easing = easing as? TimingEasing, gif = self?.gif, strongSelf = self else { return }
            strongSelf.easing = easing
            strongSelf.gif = Gif(images: gif.images, easing: easing, totalTime: Double(strongSelf.slider.value))
            
        }
        
        self.view.backgroundColor = UIColor.PDDarkGray()
        self.view.addSubview(self.gifView)
        self.view.addSubview(self.slider)
        
    }
    
    func animateIn() {
        self.easingsViewController.view.alpha = 0
        UIView.animateWithDuration(0.2) {
            self.easingsViewController.view.alpha = 1
        }
    }
    
    func sliderDidSlide(slider: UISlider) {
        guard let gif = self.gif else { return }
        let value = Double(slider.value)
        self.gif = Gif(images: gif.images, easing: self.easing, totalTime: value)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.gifView.size = CGSize(self.view.width, self.view.width)
        self.gifView.y = self.navigationController?.navigationBar.maxY ?? 0
        
        
        self.slider.sizeToFit()
        self.slider.width = self.view.width - 22
        self.slider.moveBelow(siblingView: self.gifView, margin: 48.5, alignment: .Center)

        self.easingsViewController.view.size = CGSize(width: self.gifView.width, height: 100)
        self.easingsViewController.view.moveBelow(siblingView: self.slider, margin: 8, alignment: .Center)
        
    }

}
