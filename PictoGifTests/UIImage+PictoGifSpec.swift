//
//  UIImage+PictoGifSpec.swift
//  picdive
//
//  Created by Thomas Abend on 2/20/16.
//  Copyright © 2016 Sean. All rights reserved.
//

import Quick
import Nimble
@testable
import PictoGif

class UIImagePictoGifSpec: QuickSpec {
    static let testImageName = "logo"
    
    override func spec() {
        describe("resized") {
            it("returns an image with the given size") {
                let image = UIImage(named: UIImagePictoGifSpec.testImageName)!
                let sideLength = 100
                let size = CGSize(width: sideLength, height: sideLength)
                let resized = image.resized(toSize: size)
                expect(resized.size) == size
            }
            
            it("does not alter the original image") {
                let image = UIImage(named: UIImagePictoGifSpec.testImageName)!
                let originalSize = image.size
                let sideLength = 100
                let size = CGSize(width: sideLength, height: sideLength)
                image.resized(toSize: size)
                expect(image.size) == originalSize
            }
            
        }
        
        describe("stitchImagesHorizontal") {
            let image = UIImage(named: UIImagePictoGifSpec.testImageName)!
            let resized = image.resized(toSize: CGSize(100, 100))
            let smaller = image.resized(toSize: CGSize(20, 20))
            let images = [resized, smaller]
            let stitched = UIImage.stitchImagesHorizontal(images)
            it("returns an image with a height of the tallest image") {
                expect(stitched?.size.height) == 100
            }
            
            it("returns an image with a width of the widest image * number of images") {
                expect(stitched?.size.width) == 200
            }
        }

        describe("stitchImagesVertical") {
            let image = UIImage(named: UIImagePictoGifSpec.testImageName)!
            let resized = image.resized(toSize: CGSize(100, 100))
            let smaller = image.resized(toSize: CGSize(20, 20))
            let images = [resized, smaller]
            let stitched = UIImage.stitchImagesHorizontal(images)
            it("returns an image with a width of the widest image") {
                expect(stitched?.size.width) == 200
            }
            
            it("returns an image with a height of the tallest image * number of images") {
                expect(stitched?.size.height) == 100
            }
        }
    }
}