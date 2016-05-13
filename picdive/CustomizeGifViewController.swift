//
//  CustomizeGifViewController.swift
//  picdive
//
//  Created by Thomas Abend on 4/26/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

class CustomizeGifViewController: UIViewController, FlowViewController, ImagePresenter {
    typealias Next = PublishingViewController
    var imageViewDataSource: ImageViewDataSource? {
        didSet {
            if let gif = self.imageViewDataSource as? Gif {
                self.gifView.image = gif.image
            }
        }
    }

    private let gifView = UIImageView()
    let easingsViewController = EasingViewController()
    let slider: UISlider = UISlider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Customize your Gif"
        self.setupNavigationBar()
        
        self.slider.addTarget(self, action: #selector(CustomizeGifViewController.sliderDidSlide(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.slider.minimumValue = 2
        self.slider.maximumValue = 7
        self.slider.value = 4
        self.slider.minimumTrackTintColor = UIColor.PDBlue()
        self.slider.maximumTrackTintColor = UIColor.PDLightGray()
        self.slider.thumbTintColor = UIColor.whiteColor()
        
        self.addChildViewController(self.easingsViewController)
        self.view.addSubview(self.easingsViewController.view)
        self.easingsViewController.didMoveToParentViewController(self)
        self.easingsViewController.easings = [ScopeEasing.In, ScopeEasing.Out,  ScopeEasing.Linear]
        
        self.view.backgroundColor = UIColor.PDDarkGray()
        self.view.addSubview(self.gifView)
        self.view.addSubview(self.slider)
        
    }
    
    func sliderDidSlide(slider: UISlider) {
        let roundedValue = round(slider.value)
        slider.setValue(roundedValue, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.gifView.size = CGSize(self.view.width, self.view.width)
        self.gifView.center = self.view.center
        
        self.easingsViewController.view.size = CGSize(width: self.gifView.width, height: 128)
        self.easingsViewController.view.moveAbove(siblingView: self.gifView, margin: 10, alignment: .Center)
        
        
        self.slider.sizeToFit()
        self.slider.width = self.view.width - 22
        self.slider.moveBelow(siblingView: self.gifView, margin: 12, alignment: .Center)
    }

}
