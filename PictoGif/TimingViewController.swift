//
//  TimingViewController.swift
//  PictoGif
//
//  Created by Thomas Abend on 7/15/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit
import ASValueTrackingSlider

class TimingViewController: UIViewController, ASValueTrackingSliderDataSource {
    let easingsViewController = EasingViewController()
    let slider = Slider()
    var easing = TimingEasing.FinalFrame

    var setGif: (((Void -> Void)?) -> Void)?
    
    private let sliderMax: Float = 10.0
    private let sliderMin: Float = 0.5
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.slider.addTarget(self, action: #selector(TimingViewController.sliderDidSlide(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.slider.continuous = false
        self.slider.minimumTrackTintColor = UIColor.PictoPink()
        
        self.slider.setupValues(min: self.sliderMin, max: self.sliderMax, initial: 8)
        self.slider.setupImages(min: UIImage(named: "time_turtle"), max: UIImage(named: "time_fast"))
        self.slider.dataSource = self
        
        self.easingsViewController.easings = [TimingEasing.FinalFrame,  TimingEasing.Linear, TimingEasing.Reverse, TimingEasing.ReverseFinalFrame, TimingEasing.InOut, TimingEasing.ExtraFinalFrame, TimingEasing.ReverseFirstFrame]
        
        self.addChildViewController(self.easingsViewController)
        self.view.addSubview(self.easingsViewController.view)
        self.easingsViewController.didMoveToParentViewController(self)
        
        self.easingsViewController.onClick = { [weak self] easing, completion in
            if let easing = easing as? TimingEasing {
                self?.easing = easing
            }
            self?.setGif?(completion)
        }
        
        self.view.backgroundColor = UIColor.PDDarkGray()
        
        self.view.addSubview(self.slider)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.slider.sizeToFit()
        self.slider.width = self.view.width - 22
        self.slider.y = Config.baseMargin * 2
        self.slider.moveToHorizontalCenterOfSuperview()

        
        self.easingsViewController.view.size = CGSize(width: self.slider.width, height: 100)
        self.easingsViewController.view.moveBelow(siblingView: self.slider, margin: Config.baseMargin, alignment: .Center)
        

    }
    
    
    func animateIn() {
        self.easingsViewController.view.alpha = 0
        UIView.animateWithDuration(0.2) {
            self.easingsViewController.view.alpha = 1
        }
    }
}

// MARK: - Slider
extension TimingViewController {
    func sliderDidSlide(slider: UISlider) {
        self.setGif?(nil)
    }
    
    func slider(slider: ASValueTrackingSlider!, stringForValue value: Float) -> String! {
        return "\(self.translatedSliderValue.format(".2")) seconds"
    }
    
    var translatedSliderValue: Float {
        return (self.sliderMax + self.sliderMin) - self.slider.value
    }
}