//
//  Async.swift
//  picdive
//
//  Created by Thomas Abend on 6/4/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import Foundation
public func after(nanoseconds nanoseconds: Double, exec: ()->Void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(nanoseconds)), dispatch_get_main_queue(), exec)
}

public func after(milliseconds milliseconds: Double, exec: ()->Void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(milliseconds * 1e6)), dispatch_get_main_queue(), exec)
}

public func after(seconds seconds: Double, exec: ()->Void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * 1e9)), dispatch_get_main_queue(), exec)
}

public func immediately(exec: ()->Void) {
    dispatch_async(dispatch_get_main_queue(), exec)
}

