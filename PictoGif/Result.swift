//
//  Result.swift
//  PictoGif
//
//  Created by Thomas Abend on 7/8/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import Foundation

enum Result<T: Any> {
    case Success(T)
    case Failure(ErrorType)
}

extension Result {
    
    init(_ f: () throws -> T) {
        do {
            self = .Success(try f())
        } catch let e {
            self = .Failure(e)
        }
    }
    
    func unwrap() throws -> T {
        switch self {
        case let .Success(x):
            return x
        case let .Failure(e):
            throw e
        }
    }
}