//
//  CroppingViewController.swift
//  picdive
//
//  Created by Thomas Abend on 4/26/16.
//  Copyright © 2016 Sean. All rights reserved.
//
import UIKit


class CroppingViewController: UIViewController, FlowViewController, ImagePresenter {
    
    typealias Next = ScopeViewController
    var imageViewDataSource: ImageViewDataSource? {
        didSet {
            if let image = self.imageViewDataSource as? UIImage {
                self.cropper.image = image
            }
        }
    }
    
    var nextImageViewDataSource: ImageViewDataSource? {
        return self.cropper.crop()
    }
    
    
    private let cropper = ImageCropper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Crop your image"
        self.setupNavigationBar()
        
        self.view.backgroundColor = UIColor.PDDarkGray()

        self.view.addSubview(self.cropper)
    }
    
   
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.cropper.size = CGSize(width: self.view.width, height: self.view.width)
        self.cropper.center = self.view.center
        self.cropper.setup()

    }
    
}