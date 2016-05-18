//
//  PublishingViewController.swift
//  picdive
//
//  Created by Thomas Abend on 4/26/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

class PublishingViewController : UIViewController, ImagePresenter {
    
    var imageViewDataSource: ImageViewDataSource? {
        didSet {
            if let gif = self.imageViewDataSource as? Gif {
                self.gifView.image = gif.image
            }
        }
    }

    private let gifView = UIImageView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.PDDarkGray()

        self.navigationItem.title = "Share"
        self.setupNavigationBar()
        self.view.addSubview(self.gifView)
    }
    
    func setupNavigationBar() {
        let barButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self.navigationController, action: #selector(UINavigationController.popToRootViewControllerAnimated(_:)))
        let backButton = UIBarButtonItem(title: "X", style: UIBarButtonItemStyle.Done, target: self.navigationController, action: #selector(PublishingViewController.back))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.rightBarButtonItem = barButton
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(PublishingViewController.copyGif))
        self.gifView.addGestureRecognizer(longPress)
        self.gifView.userInteractionEnabled = true
        
    }
    
    func back() {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    func copyGif() {
        guard let gif = self.imageViewDataSource as? Gif else { return }
        UIPasteboard.generalPasteboard().setData(gif.data, forPasteboardType: "com.compuserve.gif")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.gifView.size = CGSize(self.view.width, self.view.width)
        self.gifView.center = self.view.center
    }
}
