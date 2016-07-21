//
//  BarButtonItem.swift
//  PictoGif
//
//  Created by Thomas Abend on 7/8/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

class BarButtonItem: UIBarButtonItem {
    static let nextImage = UIImage(named: "right")
    static let backImage = UIImage(named: "left")
    static let cancelImage = UIImage(named: "x")
    
    
    var completion: (Void -> Void)?
    init(title: String, completion: (Void -> Void)?) {
        self.completion = completion
        super.init()
        self.title = title
        self.setTitleTextAttributes(
            [
                NSFontAttributeName : UIFont.PDFont(withSize: 16),
                NSForegroundColorAttributeName: UIColor.PictoPink(),

            ], forState: .Normal)
        self.target = self
        self.action = #selector(BarButtonItem.perform)
        self.style = .Done
    }
    
    init(image: UIImage?, completion: (Void -> Void)?) {
        self.completion = completion
        super.init()
        self.image = image
        self.target = self
        self.action = #selector(BarButtonItem.perform)
        self.style = .Done
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func perform() {
        completion?()
    }
}