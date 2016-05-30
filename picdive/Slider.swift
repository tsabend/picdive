//
//  Slider.swift
//  picdive
//
//  Created by Sean Ellis on 5/24/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

class Slider : UISlider {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.minimumTrackTintColor = UIColor.PDBlue()
        self.maximumTrackTintColor = UIColor.PDLightGray()
        self.thumbTintColor = UIColor.whiteColor()
    }
    
    func setupValues(min min: Float, max: Float, initial: Float) {
        self.minimumValue = min
        self.maximumValue = max
        self.value = initial
    }
    
    func setupImages(min min: UIImage?, max: UIImage?) {
        self.minimumValueImage = min
        self.maximumValueImage = max
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}