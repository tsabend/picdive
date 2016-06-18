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
import ASValueTrackingSlider


class ScopeViewController: UIViewController, ImagePresenter, FlowViewController, ASValueTrackingSliderDataSource, PicScopeViewDelegate {

    typealias Next = CustomizeGifViewController
    var imageViewDataSource: ImageViewDataSource? {
        didSet {
            if let image = self.imageViewDataSource as? UIImage {
                self.imageView.image = image
                self.zoomingImageView.image = image
            }
        }
    }
    
    var nextImageViewDataSource: ImageViewDataSource? {
        return self.makeGif()
    }
    
    
    private let imageView = UIImageView()
    private let zoomingImageView = ZoomingImageView()
    let slider: Slider = Slider()
    var numFrames: Int = 1

    var scope: PicScopeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Zoom!"
        self.setupNavigationBar()
        
        self.view.backgroundColor = UIColor.PDDarkGray()
        
        self.scope = PicScopeView()
        self.scope.delegate = self

        self.slider.addTarget(self, action: #selector(ScopeViewController.sliderDidSlide(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.slider.setupValues(min: 2, max: 8, initial: 4)
        self.slider.setupImages(min: UIImage(named: "frames_few"), max: UIImage(named: "frames_many"))
        self.slider.minimumTrackTintColor = UIColor.PictoPink()
        self.slider.dataSource = self
        
        self.modalTransitionStyle = .CoverVertical
        
        self.view.addSubview(self.imageView)
        self.view.addSubview(self.scope)
        self.view.addSubview(self.slider)
        self.view.addSubview(self.zoomingImageView)
    
    }
    
    func animateIn() {
        after(seconds: 0.1) { self.scope.animate() }
    }
    
    func sliderDidSlide(slider: UISlider) {
        let roundedValue = round(slider.value)
        slider.setValue(roundedValue, animated: false)
        self.scope.numberOfSteps = Int(roundedValue)
    }
    
    func slider(slider: ASValueTrackingSlider!, stringForValue value: Float) -> String! {
        return "\(Int(value)) frames"
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
        if let images = self.snapshotImages() {
            return Gif(images: images, easing: TimingEasing.FinalFrame, totalTime: Double(self.slider.value))
        }
        return nil
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let margin = 22.f
        let scrollViewSideLength = self.view.width - margin
        
        self.imageView.size = CGSize(self.view.width, self.view.width)
        self.imageView.size = CGSize(Config.imageViewWidth, Config.imageViewWidth)
        self.imageView.moveToHorizontalCenterOfSuperview()
        self.imageView.y = self.navigationController?.navigationBar.maxY ?? 0
        
        self.slider.sizeToFit()
        self.slider.width = scrollViewSideLength
        self.slider.moveBelow(siblingView: self.imageView, margin: 32, alignment: .Center)

        self.scope.frame = self.imageView.frame
        
        if self.scope.innerRect == CGRect.zero {
            let x = self.view.width / 2 - 100
            self.scope.innerRect = CGRect(x, x, 100, 100)
        }
        
        self.zoomingImageView.size = CGSize(100,100)
        self.zoomingImageView.moveToHorizontalCenterOfSuperview()
        self.zoomingImageView.alignBottom(44, toView: self.view)
    }
    
    func scopeWasMoved(toFrame frame: CGRect) {
        let origin = frame.origin * self.zoomingImageView.width / self.view.width
        let size = frame.size * self.zoomingImageView.width / self.view.width
        let rect  = CGRect(origin, size)
        self.zoomingImageView.zoom(toRect: rect)
    }
}
