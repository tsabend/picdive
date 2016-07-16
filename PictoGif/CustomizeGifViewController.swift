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
    
    var nextImageViewDataSource: ImageViewDataSource? {
        guard let gif = self.gif else { return nil }
        let topText = self.topMemeTextField.text
        let bottomText = self.bottomMemeTextField.text
        let topSize = self.topMemeTextField.font?.pointSize ?? 0
        let bottomSize = self.bottomMemeTextField.font?.pointSize ?? 0
        
        if !topText.isEmpty || !bottomText.isEmpty {
            let meme: (UIImage -> UIImage) = { (image: UIImage) -> UIImage in
                return image.meme(withTopText: topText, topSize: topSize, bottomText: bottomText, bottomSize: bottomSize)
            }
            var images = gif.images
            if self.memeAccessoryView.overAll {
                images = images.map(meme)
                
            } else {
                let memed = meme(images.last!)
                images = images.dropLast() + [memed]
            }
            return Gif(images: images, easing: gif.easing, totalTime: gif.totalTime)
        }
        return gif
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
        self.gif = Gif(images: gif.images, easing: self.timingViewController.easing, totalTime: Double(self.timingViewController.translatedSliderValue))
    }

    private let gifView = UIImageView()
    let timingViewController = TimingViewController()

    private let watermarkButton = UIButton()
    private let flash = UIView()
    private let memeButton = UIButton()
    
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
        self.topMemeTextField.font = UIFont.MemeFont(withSize: 48)
        self.topMemeTextField.textAlignment = .Center
        self.topMemeTextField.textColor = UIColor.whiteColor()
        self.topMemeTextField.backgroundColor = UIColor.clearColor()
        self.topMemeTextField.delegate = self
        self.topMemeTextField.inputAccessoryView = self.memeAccessoryView
        self.topMemeTextField.scrollEnabled = false
        self.topMemeTextField.autocorrectionType = .No
        self.topMemeTextField.returnKeyType = .Done
        
        self.bottomMemeTextField.typingAttributes = self.memeTextAttributes
        self.bottomMemeTextField.font = UIFont.MemeFont(withSize: 48)
        self.bottomMemeTextField.textAlignment = .Center
        self.bottomMemeTextField.textColor = UIColor.whiteColor()
        self.bottomMemeTextField.backgroundColor = UIColor.clearColor()
        self.bottomMemeTextField.delegate = self
        self.bottomMemeTextField.inputAccessoryView = self.memeAccessoryView
        self.bottomMemeTextField.scrollEnabled = false
        self.bottomMemeTextField.autocorrectionType = .No
        self.bottomMemeTextField.returnKeyType = .Done
        
        self.memeAccessoryView.delegate = self

        
        self.addChildViewController(self.timingViewController)
        self.view.addSubview(self.timingViewController.view)
        self.timingViewController.didMoveToParentViewController(self)
        self.watermarkButton.addTarget(self, action: #selector(CustomizeGifViewController.buyRemoveWatermark), forControlEvents: .TouchUpInside)
        self.watermarkButton.setTitle("REMOVE WATERMARK", forState: .Normal)
        self.watermarkButton.titleLabel?.font = UIFont.PDFont(withSize: 14)
        self.watermarkButton.backgroundColor = UIColor.PictoPink()
        self.watermarkButton.hidden = PicDiveProducts.hasPurchasedWatermark
        
        
        self.memeButton.addTarget(self, action: #selector(CustomizeGifViewController.meme), forControlEvents: .TouchUpInside)
        
        self.memeButton.setTitle("MEME", forState: .Normal)
        self.memeButton.titleLabel?.font = UIFont.PDFont(withSize: 14)
        self.memeButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.memeButton.layer.borderColor = UIColor.PictoPink().CGColor
        self.memeButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        self.memeButton.layer.borderWidth = 1
        self.memeButton.layer.cornerRadius = 2
        
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
        
        self.watermarkButton.size = CGSize(self.view.width, 32)
        self.watermarkButton.alignBottom(0, toView: self.view)
        
        self.memeButton.sizeToFit()
        self.memeButton.moveAbove(siblingView: self.watermarkButton, margin: 8)
        self.memeButton.alignRight(8, toView: self.view)
        
    }
    
    func meme() {
        if self.memeAccessoryView.topBottomToggle.selectedSegmentIndex == 0 {
            self.topMemeTextField.becomeFirstResponder()
        } else {
            self.bottomMemeTextField.becomeFirstResponder()
        }
    }
    
}

// MARK: - Meming
extension CustomizeGifViewController: UITextViewDelegate {
    

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" { textView.resignFirstResponder(); return false }
        let oldString = textView.text ?? ""
        let startIndex = oldString.startIndex.advancedBy(range.location)
        let endIndex = startIndex.advancedBy(range.length)
        let newString = oldString.stringByReplacingCharactersInRange(startIndex ..< endIndex, withString: text)
        
        let minSize: CGFloat = 30
        var fontSize: CGFloat = 48
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
    
    func textViewDidBeginEditing(textView: UITextView) {
        textView.backgroundColor = UIColor.PDLightGray().colorWithAlphaComponent(0.33)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        textView.backgroundColor = UIColor.clearColor()
    }
    
    
}
// MARK: - Watermark Purchase
extension CustomizeGifViewController {
    func buyRemoveWatermark() {
        let vc = UIAlertController(title: "Remove watermark", message: "Tired of seeing our logo on your PictoGifs? Pay once and remove it forever.", preferredStyle: .Alert)
        vc.addAction(UIAlertAction(title: "🙌 Yaaaaas 🙌", style: .Default) { (_) in
            PicDiveProducts.store.buyProduct(withIdentifier: PicDiveProducts.RemoveWatermark)
            })
        
        vc.addAction(UIAlertAction(title: "Restore Previous Purchase", style: .Default) { (_) in
            PicDiveProducts.store.restorePurchases()
            })
        
        vc.addAction(UIAlertAction(title: "Not now", style: .Cancel, handler: { _ in NSUserDefaults.standardUserDefaults().setBool(false, forKey: "hasPaid")
            self.setGif()
        }))
        Answers.logCustomEventWithName("Remove watermark button pressed", customAttributes: [:])
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func removeWatermark() {
        self.setGif()
        self.watermarkButton.hidden = true
    }
    
    func reportFailure(notification: NSNotification) {
        let message = notification.object as? String ?? "The purchase failed. Check your connection or try again later."
        let vc = UIAlertController(title: "Womp", message: message, preferredStyle: .Alert)
        vc.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        self.presentViewController(vc, animated: true, completion: nil)
    }
}

@objc protocol MemeAccessoryViewDelegate: class {
    func textFieldDidSwitch(toPosition positon: MemePosition)
}

extension CustomizeGifViewController : MemeAccessoryViewDelegate {
    func textFieldDidSwitch(toPosition positon: MemePosition) {
        if positon == .Top {
            self.bottomMemeTextField.resignFirstResponder()
            self.topMemeTextField.becomeFirstResponder()
        } else {
            self.topMemeTextField.resignFirstResponder()
            self.bottomMemeTextField.becomeFirstResponder()
        }
    }
}

@objc enum MemePosition: Int {
    case Top, Bottom
}

class MemeAccessoryView: UIView {
    var overAll : Bool {
        return self.allFinalToggle.selectedSegmentIndex == 0
    }
    private let allFinalToggle = UISegmentedControl()
    private let topBottomToggle = UISegmentedControl()
    
    var delegate : MemeAccessoryViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
        
        self.topBottomToggle.insertSegmentWithTitle("Top", atIndex: 0, animated: false)
        self.topBottomToggle.insertSegmentWithTitle("Bottom", atIndex: 1, animated: false)
        self.topBottomToggle.tintColor = UIColor.PDBlue()
        self.topBottomToggle.selectedSegmentIndex = 0
        
        self.allFinalToggle.insertSegmentWithTitle("Over All", atIndex: 0, animated: false)
        self.allFinalToggle.insertSegmentWithTitle("Over Last", atIndex: 1, animated: false)
        self.allFinalToggle.tintColor = UIColor.PDBlue()
        self.allFinalToggle.selectedSegmentIndex = 0
        
        self.topBottomToggle.addTarget(self, action: #selector(MemeAccessoryView.toggle), forControlEvents: .ValueChanged)
        
        self.addSubview(self.topBottomToggle)
        self.addSubview(self.allFinalToggle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.topBottomToggle.sizeToFit()
        self.topBottomToggle.moveToVerticalCenterOfSuperview()
        self.topBottomToggle.x = 8
        
        self.allFinalToggle.sizeToFit()
        self.allFinalToggle.moveToVerticalCenterOfSuperview()
        self.allFinalToggle.alignRight(8, toView: self)
        
    }
    
    func toggle() {
        if self.topBottomToggle.selectedSegmentIndex == 0 {
            self.delegate?.textFieldDidSwitch(toPosition: .Top)
        } else {
            self.delegate?.textFieldDidSwitch(toPosition: .Bottom)
        }
    }
    
    
}
