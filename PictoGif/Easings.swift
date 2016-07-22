//
//  Easings.swift
//  picdive
//
//  Created by Thomas Abend on 5/30/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import UIKit

protocol EasingType {
    var text: String { get }
    var image: UIImage? { get }
}

/// The easing type for setting the duration of images within a gif.
enum TimingEasing: EasingType {
    case Linear, FinalFrame, Reverse, ReverseFinalFrame, ExtraFinalFrame, InOut, ReverseFirstFrame
    var text: String {
        switch self {
        case .Linear:
            return "Normal"
        case .FinalFrame:
            return "Freeze Frame"
        case .Reverse:
            return "Reverse"
        case .ReverseFinalFrame:
            return "Reverse and Freeze"
        case .ExtraFinalFrame:
            return "Extra Long Freeze"
        case .InOut:
            return "In and Out"
        case .ReverseFirstFrame:
            return "Freeze and Reverse"
        }
    }
    
    
    var image: UIImage? {
        return UIImage(named: self.imageName)
    }
    
    private var imageName: String {
        switch self {
        case .Linear:
            return "linear"
        case .FinalFrame:
            return "final_frame"
        case .ReverseFinalFrame:
            return "final_frame_reverse"
        case .Reverse:
            return "linear_reverse"
        default:
            return "linear" // FIXME: Add new assets for new easings
        }
    }
    
    var reversed: Bool {
        switch self {
        case .Reverse, .ReverseFinalFrame, .ReverseFirstFrame:
            return true
        default:
            return false
        }
    }
    
    func times(framesCount count: Int, totalTime duration: Double) -> [Double] {
        switch self {
        case .Linear, .Reverse:
            return (0..<count).map {_ in duration/count.d}
        case .InOut:
            return (0..<count * 2).map {_ in duration/count.d}
        case .FinalFrame, .ReverseFinalFrame:
            let finalFrameTax = 0.2
            return self.timingForFinalFrame(withTax: finalFrameTax, count: count, duration: duration)
        case .ReverseFirstFrame:
            let finalFrameTax = 0.2
            return self.timingForFinalFrame(withTax: finalFrameTax, count: count, duration: duration).reverse()
        case .ExtraFinalFrame:
            let finalFrameTax = 0.5
            return self.timingForFinalFrame(withTax: finalFrameTax, count: count, duration: duration)
        }
    }
    
    private func timingForFinalFrame(withTax finalFrameTax: Double, count: Int, duration: Double) -> [Double] {
        let normalFrameDuration = duration/count.d * (1.0 - finalFrameTax)
        let finalFrameDuration = duration/count.d + ((duration/count.d) * finalFrameTax * (count.d - 1.0))
        var norms = (0..<count - 1).map { _ in normalFrameDuration }
        norms.append(finalFrameDuration)
        return norms
    }
    
}
