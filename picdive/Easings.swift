//
//  Easings.swift
//  picdive
//
//  Created by Thomas Abend on 5/30/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import Foundation

protocol EasingType {
    var label: String { get }
}

/// The easing type for setting the duration of images within a gif.
enum TimingEasing: EasingType {
    case Linear, FinalFrame, Reverse, ReverseFinalFrame
    var label: String {
        switch self {
        case .Linear:
            return "Lin"
        case .FinalFrame:
            return "Final"
        case .Reverse:
            return "Rev"
        case .ReverseFinalFrame:
            return "Rev Final"
        }
    }
    
    var reversed: Bool {
        switch self {
        case .Reverse, .ReverseFinalFrame:
            return true
        default:
            return false
        }
    }
    
    func times(framesCount count: Int, totalTime duration: Double) -> [Double] {
        switch self {
        case .Linear, .Reverse:
            return (0..<count).map {_ in duration/count.d}
        case .FinalFrame, .ReverseFinalFrame:
            let finalFrameTax = 0.15
            let normalFrameDuration = duration/count.d * (1.0 - finalFrameTax)
            let finalFrameDuration = duration/count.d + ((duration/count.d) * finalFrameTax * (count.d - 1.0))
            var norms = (0..<count - 1).map { _ in normalFrameDuration }
            norms.append(finalFrameDuration)
            return norms
        }
    }
    
}
