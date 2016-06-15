//
//  Slider.swift
//  picdive
//
//  Created by Sean Ellis on 5/24/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit
import ASValueTrackingSlider

class Slider : ASValueTrackingSlider {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.minimumTrackTintColor = UIColor.PDBlue()
        self.maximumTrackTintColor = UIColor.PDLightGray()
        self.thumbTintColor = UIColor.whiteColor()
        self.popUpViewColor = UIColor.PictoPink()
        self.font = UIFont.PDFont(withSize: 18)
        self.popUpViewArrowLength = 18
        self.setThumbImage(UIImage(named: "slider_thumb")?.resized(toSize: CGSize(44,22)), forState: .Normal)
        self.setThumbImage(UIImage(named: "slider_thumb_highlighted")?.resized(toSize: CGSize(44,22)), forState: .Highlighted)
    }
    
    func setupValues(min min: Float, max: Float, initial: Float) {
        self.minimumValue = min
        self.maximumValue = max
        self.value = initial
    }
    
    func setupImages(min min: UIImage?, max: UIImage?) {
        let min = min?.resized(toSize: CGSize(22, 22))
        let max = max?.resized(toSize: CGSize(22, 22))
        self.minimumValueImage = min
        self.maximumValueImage = max
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}