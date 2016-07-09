//
//  NumberConversions+PicDive.swift
//  picdive
//
//  Created by Thomas Abend on 5/30/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

extension Int {
    var f: CGFloat {
        return CGFloat(self)
    }
    
    var d: Double {
        return Double(self)
    }
}

extension CGFloat {
    var d: Double {
        return Double(self)
    }
}


extension Float {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

extension CFString {
    var s: String {
        return String(self)
    }
}