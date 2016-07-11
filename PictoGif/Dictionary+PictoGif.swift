//
//  Dictionary+PictoGif.swift
//  PictoGif
//
//  Created by Thomas Abend on 7/8/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import Foundation

func += <K, V> (inout left: [K:V], right: [K:V]) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}