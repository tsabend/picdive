//
//  ViewController.swift
//  picdive
//
//  Created by Sean on 2/17/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit
import SwiftGifOrigin
import CGRectExtensions

class ScopeViewController: UIViewController {

    let imageView: UIImageView = UIImageView()

    let slider: UISlider = UISlider()
    var numFrames: Int = 1

    var scope: PicScopeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Enhance!"
        let barButton = UIBarButtonItem(title: "✔", style: UIBarButtonItemStyle.Done, target: self, action: #selector(ScopeViewController.segueToCustomize))
        let backButton = UIBarButtonItem(title: "X", style: UIBarButtonItemStyle.Done, target: self.navigationController, action: #selector(UINavigationController.popViewControllerAnimated(_:)))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.rightBarButtonItem = barButton
        
        self.view.backgroundColor = UIColor.PDDarkGray()
        
        self.scope = PicScopeView()

        self.slider.addTarget(self, action: #selector(ScopeViewController.sliderDidSlide(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.slider.minimumValue = 1
        self.slider.maximumValue = 8
        self.slider.value = 4
        self.slider.minimumTrackTintColor = UIColor.PDBlue()
        self.slider.maximumTrackTintColor = UIColor.PDLightGray()
        self.slider.thumbTintColor = UIColor.whiteColor()
        
        self.modalTransitionStyle = .CoverVertical
       
        self.view.addSubview(self.imageView)
        self.view.addSubview(self.scope)
        self.view.addSubview(self.slider)
    
    }
    
    func segueToCustomize() {
        let vc = CustomizeGifViewController()
        vc.gif = self.makeGif()
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func sliderDidSlide(slider: UISlider) {
        let roundedValue = round(slider.value)
        slider.setValue(roundedValue, animated: false)
        self.scope.numberOfSteps = Int(roundedValue)
    }
    
    private func snapshotImages() -> [UIImage]? {
        guard let image = self.imageView.image else { return nil }
        
        return self.scope.frames.map { (rect: CGRect) -> UIImage in
            return image
                .cropped(inRect: rect)
                .resized(toSize: self.imageView.size)
        }
    }
    
    private func makeGif() -> Gif? {
        let time = Double(4 / self.slider.value)
        if let images = self.snapshotImages() {
            return Gif(images: images, delay: time)
        }
        return nil
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let margin = 22.f
        let scrollViewSideLength = self.view.width - margin
        
        self.imageView.size = CGSize(self.view.width, self.view.width)
        self.imageView.center = self.view.center
        
        self.slider.sizeToFit()
        self.slider.width = scrollViewSideLength
        self.slider.moveBelow(siblingView: self.imageView, margin: 10, alignment: .Center)
        
        
        self.scope.frame = self.imageView.frame
        if self.scope.innerRect == CGRect.zero {
            self.scope.innerRect = CGRect(150, 150, 100, 100)
        }
        
    }
}
