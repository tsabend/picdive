
//
//  File.swift
//  picdive
//
//  Created by Thomas Abend on 4/28/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

class BarButtonItem: UIBarButtonItem {
    
    var completion: (Void -> Void)?
    init(title: String, completion: (Void -> Void)?) {
        self.completion = completion
        super.init()
        self.title = title
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

protocol ImageViewDataSource {}
extension UIImage: ImageViewDataSource {}
extension Gif: ImageViewDataSource {}

protocol ImagePresenter {
    
    var imageViewDataSource: ImageViewDataSource? { get set }
    var nextImageViewDataSource: ImageViewDataSource? { get }
    
}

extension ImagePresenter {
    var nextImageViewDataSource: ImageViewDataSource? {
        return self.imageViewDataSource
    }
}

protocol FlowViewController {
    associatedtype Next: ImagePresenter
    
    func toNext()
    func back()
    func setupNavigationBar()

}

extension FlowViewController where Self: UIViewController, Self: ImagePresenter, Next: UIViewController, Next: ImagePresenter {
    
    
    func toNext() {
        var vc = Next()
        vc.imageViewDataSource = self.nextImageViewDataSource
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func back() {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    func setupNavigationBar() {
        self.navigationItem.title = self.title
        let nextButton = BarButtonItem(title: "✔") { [weak self] in self?.toNext() }
        let backButton = BarButtonItem(title: "X") { [weak self] in self?.back() }
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.rightBarButtonItem = nextButton
    }
}