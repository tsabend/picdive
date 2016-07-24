//
//  CustomizeGifViewController.swift
//  picdive
//
//  Created by Thomas Abend on 4/26/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit
import Crashlytics

class CustomizeGifViewController: UIViewController, FlowViewController, ImagePresenter {
    typealias Next = PublishingViewController
    var imageViewDataSource: ImageViewDataSource? {
        didSet {
            if let gif = self.gif {
                self.gifView.image = gif.image
            }
        }
    }

    let memeTextAttributes = [
        NSStrokeColorAttributeName: UIColor.blackColor(),
        NSForegroundColorAttributeName: UIColor.whiteColor(),
        NSStrokeWidthAttributeName: -3.0,
        ]
    
    var gif: Gif? {
        get { return self.imageViewDataSource as? Gif }
        set { self.imageViewDataSource = newValue }
    }
    
    func setGif() {
        guard let gif = self.gif else { return }
        self.flash.flash()
        self.gif = Gif(images: gif.images, easing: self.timingViewController.easing, totalTime: Double(self.timingViewController.translatedSliderValue), memeInfo: self.memeInfo, watermarkedImages: gif.watermarkedImages)
    }

    private let gifView = UIImageView()
    let timingViewController = TimingViewController()

    let watermarkButton = UIButton()
    private let flash = UIView()
    private var memeButton = UIButton()
    private let topMemeTextField = UITextView()
    private let bottomMemeTextField = UITextView()
    private lazy var memeAccessoryView: MemeAccessoryView = MemeAccessoryView(frame: CGRect(CGPoint.zero, CGSize(self.view.width, 44)))
    
    
    // MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false

        self.title = "Customize your Gif"
        self.setupNavigationBar()
        
        self.timingViewController.setGif = self.setGif
             
        self.flash.backgroundColor = UIColor.whiteColor()
        self.flash.alpha = 0
        
        self.topMemeTextField.typingAttributes = self.memeTextAttributes
        self.topMemeTextField.font = UIFont.MemeFont(withSize: 54)
        self.topMemeTextField.textAlignment = .Center
        self.topMemeTextField.textColor = UIColor.whiteColor()
        
        self.topMemeTextField.delegate = self
        self.topMemeTextField.inputAccessoryView = self.memeAccessoryView
        self.topMemeTextField.scrollEnabled = false
        self.topMemeTextField.autocorrectionType = .No
        self.topMemeTextField.returnKeyType = .Done
        
        self.bottomMemeTextField.typingAttributes = self.memeTextAttributes
        self.bottomMemeTextField.font = UIFont.MemeFont(withSize: 54)
        self.bottomMemeTextField.textAlignment = .Center
        self.bottomMemeTextField.textColor = UIColor.whiteColor()
        
        self.bottomMemeTextField.delegate = self
        self.bottomMemeTextField.inputAccessoryView = self.memeAccessoryView
        self.bottomMemeTextField.scrollEnabled = false
        self.bottomMemeTextField.autocorrectionType = .No
        self.bottomMemeTextField.returnKeyType = .Done
        
        self.topMemeTextField.backgroundColor = UIColor.PDLightGray().colorWithAlphaComponent(0.33)
        self.bottomMemeTextField.backgroundColor = UIColor.PDLightGray().colorWithAlphaComponent(0.33)
        
        self.topMemeTextField.hidden = true
        self.bottomMemeTextField.hidden = true
        
        self.memeAccessoryView.delegate = self
        
        self.addChildViewController(self.timingViewController)
        self.view.addSubview(self.timingViewController.view)
        self.timingViewController.didMoveToParentViewController(self)
        self.watermarkButton.addTarget(self, action: #selector(CustomizeGifViewController.buyRemoveWatermark), forControlEvents: .TouchUpInside)
        self.watermarkButton.setTitle("REMOVE WATERMARK", forState: .Normal)
        self.watermarkButton.titleLabel?.font = UIFont.PDFont(withSize: 14)
        self.watermarkButton.backgroundColor = UIColor.PictoPink()
        self.watermarkButton.hidden = PicDiveProducts.hasPurchasedWatermark
        
        self.memeButton.addTarget(self, action: #selector(CustomizeGifViewController.beginMeming), forControlEvents: .TouchUpInside)
        self.memeButton.setTitle("ADD MEME TEXT", forState: .Normal)
        self.memeButton.titleLabel?.font = UIFont.PDFont(withSize: 14)
        self.memeButton.backgroundColor = UIColor.PDBlue()
        
        self.view.backgroundColor = UIColor.PDDarkGray()
        
        self.view.addSubview(self.gifView)
        self.gifView.addSubview(self.flash)
        self.gifView.addSubview(self.topMemeTextField)
        self.gifView.addSubview(self.bottomMemeTextField)
        self.view.addSubview(self.watermarkButton)
        self.view.addSubview(self.memeButton)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomizeGifViewController.removeWatermark), name: IAPHelper.IAPHelperPurchaseNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomizeGifViewController.reportFailure), name: IAPHelper.IAPHelperPurchaseFailedNotification, object: nil)
        
    }
    
    func animateIn() {
        self.timingViewController.animateIn()
    }
    
    var isMeming: Bool {
        return self.topMemeTextField.isFirstResponder() || self.bottomMemeTextField.isFirstResponder()
    }
    
    func toNext() {
        if self.isMeming {
            self.view.endEditing(true)
            self.endMeming()
        }
        let vc = Next()
        vc.imageViewDataSource = self.nextImageViewDataSource
        self.navigationController?.pushViewController(vc, animated: false)
        vc.animateIn()
    }
    
    
    let maxTextViewHeight: CGFloat = 116
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.gifView.size = CGSize(Config.imageViewWidth, Config.imageViewWidth)
        self.gifView.moveToHorizontalCenterOfSuperview()
        self.gifView.y = self.navigationController?.navigationBar.maxY ?? 0
        
        self.flash.frame = self.gifView.bounds
        
        self.topMemeTextField.sizeToFit()
        self.topMemeTextField.width = self.gifView.width
        self.bottomMemeTextField.sizeToFit()
        self.bottomMemeTextField.width = self.gifView.width
        
        self.bottomMemeTextField.alignBottom(0, toView: self.gifView)
        
        self.timingViewController.view.width = self.view.width
        self.timingViewController.view.height = self.view.height - self.gifView.maxY
        self.timingViewController.view.y = self.gifView.maxY
        
        self.watermarkButton.size = CGSize(self.view.width / 2, 44)
        self.watermarkButton.alignBottom(0, toView: self.view)
        
        if self.watermarkButton.hidden {
            self.memeButton.size = CGSize(self.view.width, 44)
            self.memeButton.alignBottom(0, toView: self.view)
        } else {
            self.memeButton.size = CGSize(self.view.width/2, 44)
            self.memeButton.moveRight(siblingView: self.watermarkButton, margin: 0, alignVertically: true)
  
        }

    }
    
    
    var memeInfo : MemeInfo? {
        let topText = self.topMemeTextField.text
        let bottomText = self.bottomMemeTextField.text
        guard !topText.isEmpty || !bottomText.isEmpty else { return nil }
        return MemeInfo(topText: topText, topFontSize: self.topMemeTextField.font!.pointSize, bottomText: bottomText, bottomFontSize: self.bottomMemeTextField.font!.pointSize, overAll: self.memeAccessoryView.overAll)
    }
    
    func beginMeming() {
        guard let gif = self.gif else { return }
        self.gif = Gif(images: gif.images, easing: self.timingViewController.easing, totalTime: Double(self.timingViewController.translatedSliderValue), memeInfo: nil)
        self.setImageForMeming()
        self.topMemeTextField.hidden = false
        self.bottomMemeTextField.hidden = false
        self.gifView.userInteractionEnabled = true
        self.topMemeTextField.becomeFirstResponder()

    }
    
    func endMeming() {
        self.view.endEditing(true)
        self.topMemeTextField.hidden = true
        self.bottomMemeTextField.hidden = true
        self.gifView.userInteractionEnabled = false
        self.setGif()
    }
    
}

// MARK: - Meming
extension CustomizeGifViewController: UITextViewDelegate {
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        guard let range = textView.text.rangeFromNSRange(range) else { return false }
        if text == "\n" { textView.resignFirstResponder(); self.endMeming(); return false }

        let newString = textView.text.stringByReplacingCharactersInRange(range, withString: text)
        
        let minSize: CGFloat = 30
        var fontSize: CGFloat = 54
        let sample = UITextView()
        sample.font = textView.font?.fontWithSize(fontSize)
        sample.text = newString
        while fontSize > minSize
            && sample.sizeThatFits(CGSize(textView.width, CGFloat.max)).height >= self.maxTextViewHeight {
            fontSize -= 1.0
            sample.font = textView.font?.fontWithSize(fontSize)
        }
        textView.font = sample.font
        
        let padding = textView.textContainer.lineFragmentPadding  * 2
        let newSize = textView.font?.sizeOf(string: newString, constrainedToWidth: textView.width - padding) ?? CGSize.zero
        self.view.setNeedsLayout()
        
        return newSize.height < self.maxTextViewHeight
    }
}

extension CustomizeGifViewController : MemeAccessoryViewDelegate {
   
    func allFinalWasToggled() {
        self.setImageForMeming()
    }
    
    private func setImageForMeming() {
        if self.memeAccessoryView.overAll  {
            self.gifView.image = self.gif?.image
        } else {
            self.gifView.image = self.gif?.lastImage
        }
    }
}

