//
//  RenderSettings.swift
//  PictoGif
//
//  Created by Thomas Abend on 6/11/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import AVFoundation
import UIKit

struct RenderSettings {
    
    let size: CGSize
    let avCodecKey = AVVideoCodecH264
    let videoFilename = "pictogif"
    let videoFilenameExt = "mp4"
    
    private var cacheDirectoryURL: NSURL {
        // Use the CachesDirectory so the rendered video file sticks around as long as we need it to.
        // Using the CachesDirectory ensures the file won't be included in a backup of the app.
        return try! NSFileManager
            .defaultManager()
            .URLForDirectory(.CachesDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
    }
    
    var outputURL: NSURL {
        return self.cacheDirectoryURL
            .URLByAppendingPathComponent(self.videoFilename)
            .URLByAppendingPathExtension(self.videoFilenameExt)
    }
    
    
}
