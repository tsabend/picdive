//
//  CroppingViewController.swift
//  picdive
//
//  Created by Thomas Abend on 4/26/16.
//  Copyright © 2016 Sean. All rights reserved.
//
import UIKit

class CroppingViewController: UIViewController {
  
    var image: UIImage? {
        didSet {
            self.cropper.image = self.image
        }
    }
    
    private let cropper = ImageCropper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Crop your image"
        let barButton = UIBarButtonItem(title: "✔", style: UIBarButtonItemStyle.Done, target: self, action: #selector(CroppingViewController.segueToDive))
        let backButton = UIBarButtonItem(title: "X", style: UIBarButtonItemStyle.Done, target: self.navigationController, action: #selector(UINavigationController.popViewControllerAnimated(_:)))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.rightBarButtonItem = barButton
        
        self.view.backgroundColor = UIColor.PDDarkGray()

        self.view.addSubview(self.cropper)
    }
    
    func segueToDive() {
        let vc = ScopeViewController()
        vc.imageView.image = self.cropper.crop()
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.cropper.size = CGSize(width: self.view.width, height: self.view.width)
        self.cropper.center = self.view.center
        self.cropper.setup()

    }
    
}