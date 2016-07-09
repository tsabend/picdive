
//
//  BarButtonItem.swift
//  picdive
//
//  Created by Thomas Abend on 4/28/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

protocol ImageViewDataSource {}
extension UIImage: ImageViewDataSource {}
extension Gif: ImageViewDataSource {}

protocol ImagePresenter {
    
    var imageViewDataSource: ImageViewDataSource? { get set }
    var nextImageViewDataSource: ImageViewDataSource? { get }
    func animateIn()
    
}

extension ImagePresenter {
    var nextImageViewDataSource: ImageViewDataSource? {
        return self.imageViewDataSource
    }
    func animateIn() {}
}

protocol FlowViewController {
    associatedtype Next: ImagePresenter
    
    func toNext()
    func back()
    func setupNavigationBar()

}

extension FlowViewController where Self: UIViewController, Self: ImagePresenter, Next: UIViewController {
    
    func toNext() {
        var vc = Next()
        vc.imageViewDataSource = self.nextImageViewDataSource
        self.navigationController?.pushViewController(vc, animated: false)
        vc.animateIn()
    }
    
    func back() {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    func setupNavigationBar() {
        self.navigationItem.title = self.title
        
        let backButton = BarButtonItem(image: BarButtonItem.backImage) { [weak self] in self?.back() }
        self.navigationItem.leftBarButtonItem = backButton
       
        let nextButton = BarButtonItem(image: BarButtonItem.nextImage) { [weak self] in self?.toNext() }
        self.navigationItem.rightBarButtonItem = nextButton
    }
}