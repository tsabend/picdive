//
//  CustomizeGifViewController+IAP.swift
//  PictoGif
//
//  Created by Thomas Abend on 7/20/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit
import Crashlytics

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