//
//  UIView+Helpers.swift
//  picdive
//
//  Created by Thomas Abend on 2/20/16.
//  Copyright © 2016 Sean. All rights reserved.
//
import UIKit


extension UIView {
    
    var size: CGSize {
        get { return self.frame.size }
        set { self.frame.size = newValue }
    }
    
    var width: CGFloat {
        get { return self.size.width }
        set { self.size.width = newValue }
    }
    
    var height: CGFloat {
        get { return self.size.height }
        set { self.size.height = newValue }
    }

    var origin: CGPoint {
        get { return self.frame.origin }
        set { self.frame.origin = newValue }
    }
    
    var x: CGFloat {
        get { return self.origin.x }
        set { self.origin.x = newValue }
    }
    
    var y: CGFloat {
        get { return self.origin.y }
        set { self.origin.y = newValue }
    }

    var maxX: CGFloat {
        get { return self.frame.maxX }
    }
    
    var maxY: CGFloat {
        get { return self.frame.maxY }
    }
    
    func alignRight(rightMargin: CGFloat, toView view: UIView) {
        self.x = view.bounds.width - self.bounds.width - rightMargin
    }
    
    func alignBottom(bottomMargin: CGFloat, toView view: UIView) {
        self.y = view.bounds.height - self.bounds.height - bottomMargin
    }
    
    func moveToVerticalCenter(ofView view: UIView) -> Void {
        self.y = view.bounds.size.height / 2.0 - self.bounds.size.height / 2.0
    }
    
    func moveToHorizontalCenter(ofView view: UIView) {
        self.x = view.bounds.size.width / 2.0 - self.bounds.size.width / 2.0
    }

    func moveToCenter(ofView view: UIView) {
        self.moveToHorizontalCenter(ofView: view)
        self.moveToVerticalCenter(ofView: view)
    }
    
    func moveToCenterOfSuperview() {
        if let superview = self.superview {            
            self.moveToCenter(ofView: superview)
        }
    }

    func moveBelow(siblingView view: UIView, margin: CGFloat) {
        self.moveBelow(siblingView: view, margin: margin, alignment: .None)
    }
    
    enum Alignment {
        case Left, Right, Center, None
    }
    
    func moveBelow(siblingView view: UIView, margin: CGFloat, alignment: Alignment) {
        self.y = CGRectGetMaxY(view.frame) + margin
        self.centerHorizontally(view, alignment: alignment)
    }
    
    func centerHorizontally(view: UIView, alignment: Alignment = .Center) {
        switch alignment {
        case .Left:
            self.x = view.x
        case .Right:
            self.x = view.frame.maxX - self.bounds.width
        case .Center:
            self.center.x = view.center.x
        case .None:
            break
        }
    }

    func moveAbove(siblingView view: UIView, margin: CGFloat, alignment: Alignment) {
        self.y = CGRectGetMinY(view.frame) - self.height - margin
        self.centerHorizontally(view, alignment: alignment)
    }
    
    func moveAbove(siblingView view: UIView, margin: CGFloat) {
            self.moveAbove(siblingView: view, margin: margin, alignment: .None)
    }
    
    func moveRight(siblingView view: UIView, margin: CGFloat, alignVertically: Bool = false){
        self.x = view.frame.maxX + margin
        if alignVertically {
            self.centerVertically(toSiblingView: view)
        }
    }

    func moveLeft(siblingView view: UIView, margin: CGFloat, alignVertically: Bool = false) {
        self.x = view.frame.x - self.bounds.width - margin
        if alignVertically {
            self.centerVertically(toSiblingView: view)
        }
    }
    
    func centerVertically(toSiblingView view: UIView){
        self.center.y = view.frame.center.y
    }
    
    
    func closest<T>(type: T.Type) -> T? {
        if self is T { return self as? T }
        return superview?.closest(T.self)
    }

}
