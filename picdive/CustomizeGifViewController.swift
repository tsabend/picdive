//
//  CustomizeGifViewController.swift
//  picdive
//
//  Created by Thomas Abend on 4/26/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

class CustomizeGifViewController: UIViewController {
    var gif: Gif? {
        didSet {
            self.gifView.image = gif?.image
        }
    }
    
    private let gifView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Customize your Gif"
        let barButton = UIBarButtonItem(title: "✔", style: UIBarButtonItemStyle.Done, target: self, action: #selector(CustomizeGifViewController.segueToPublish))
        let backButton = UIBarButtonItem(title: "X", style: UIBarButtonItemStyle.Done, target: self.navigationController, action: #selector(UINavigationController.popViewControllerAnimated(_:)))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.rightBarButtonItem = barButton
        self.view.backgroundColor = UIColor.PDDarkGray()

        self.view.addSubview(self.gifView)
        
    }
    
    func segueToPublish() {
        let vc = PublishingViewController()
        vc.gif = self.gif
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.gifView.size = CGSize(self.view.width, self.view.width)
        self.gifView.center = self.view.center
        
        
    }
    

}
