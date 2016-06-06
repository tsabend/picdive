//
//  Array+PicDive.swift
//  picdive
//
//  Created by Thomas Abend on 5/18/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import Foundation

public extension CollectionType where Index: Comparable {
    /// Safe collection indexing
    /// Thanks Brent Royal-Gordon via Erica Sadun
    /// (http://twitter.com/brentdax/status/613894991778222081)
    public subscript (safe index: Index) -> Generator.Element? {
        guard startIndex <= index && index < endIndex else {
            return nil
        }
        return self[index]
    }
}