//
//  PhotoRetriever.swift
//  picdive
//
//  Created by Thomas Abend on 4/23/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit
import Photos



struct PhotoRetriever {
    func queryPhotos(@noescape queryCallback: ([(UIImage?, PHAsset)]? -> Void)) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions)
        
        var images: [(UIImage?, PHAsset)] = []
        let contentMode: PHImageContentMode = PHImageContentMode.AspectFill
        fetchResult.enumerateObjectsUsingBlock { (object, index, stop) in
            let options = PHImageRequestOptions()
            options.synchronous = true
            options.deliveryMode = .Opportunistic
            let sideLength = UIScreen.mainScreen().bounds.width / 4
            let size = CGSize(width: sideLength, height: sideLength)
            PHImageManager.defaultManager().requestImageForAsset(object as! PHAsset, targetSize: size, contentMode: contentMode, options: options) {
                image, info in
                images.append((image, object as! PHAsset))
            }
        }
        queryCallback(images)
    }
    
    func getImage(asset: PHAsset, queryCallback: (UIImage? -> Void)) {
        let options = PHImageRequestOptions()
        let contentMode: PHImageContentMode = PHImageContentMode.Default
        options.synchronous = true
        options.deliveryMode = .HighQualityFormat
        
        
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: PHImageManagerMaximumSize, contentMode: contentMode, options: options) {
            image, info in
            queryCallback(image)
        }
    }
}