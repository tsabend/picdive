//
//  UIImage+PicDiveSpec.swift
//  picdive
//
//  Created by Thomas Abend on 2/20/16.
//  Copyright © 2016 Sean. All rights reserved.
//

@testable
import picdive
import Quick
import Nimble

class UIImagePicDiveSpec: QuickSpec {
    static let testImageName = "bee-test-image"
    
    override func spec() {
        describe("resized") {
            it("returns an image with the given size") {
                let image = UIImage(named: UIImagePicDiveSpec.testImageName)!
                let sideLength = 100
                let size = CGSize(width: sideLength, height: sideLength)
                let resized = image.resized(toSize: size)
                expect(resized.size) == size
            }
            
            it("does not alter the original image") {
                let image = UIImage(named: UIImagePicDiveSpec.testImageName)!
                let originalSize = image.size
                let sideLength = 100
                let size = CGSize(width: sideLength, height: sideLength)
                image.resized(toSize: size)
                expect(image.size) == originalSize
            }
            
        }
        
        describe("math") {
            it("works") {
                expect(1 + 1) == 2
            }
        }
    }
}