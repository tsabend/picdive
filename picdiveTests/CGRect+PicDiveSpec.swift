//
//  CGRect+PicDiveSpec.swift
//  picdive
//
//  Created by Thomas Abend on 5/1/16.
//  Copyright © 2016 Sean. All rights reserved.
//

@testable
import picdive
import Quick
import Nimble
import CGRectExtensions


class CGRectPicDiveSpec: QuickSpec {
    override func spec() {
        describe("squaresBetween") {
            let rect = CGRect(0, 0, 100, 100)
            let other = CGRect(12, 9, 25, 25)
            
            it("returns an empty array if both rects are not squares") {
                expect(rect.squaresBetween(rect: CGRect(0,0, 1, 2), steps: 4).count) == 0
            }
            
            it("returns an empty array if the otherRect is larger than the rect") {
                expect(rect.squaresBetween(rect: CGRect(0,0, 101, 2), steps: 4).count) == 0
            }
            
            context(".Linear") {
                let rects = rect.squaresBetween(rect: other, steps: 4, easing: .Linear)
                it("returns an array of rects with count equal to the number of steps") {
                    expect(rects.count) == 4
                }
                
                it("the first rect is the initial rect") {
                    expect(rects.first) == rect
                }
                
                it("the last rect is the other rect") {
                    expect(rects.last) == other
                }
                
                it("each rect is smaller than the previous by the ratio of the sizes * the larger size") {
                    expect(other.width/rect.width) == 0.25
                    expect(rects[0].width) == rect.width
                    expect(rects[1].width) == rect.width - 25
                    expect(rects[2].width) == rect.width - 50
                    expect(rects[3].width) == rect.width - 75
                }
                
                it("each rect is shifted from the previous by the difference of the origins") {
                    expect(rects[0].x) == rect.x
                    expect(rects[1].x) == rect.x + 4
                    expect(rects[2].x) == rect.x + 8
                    expect(rects[3].x) == rect.x + 12
                    
                    expect(rects[0].y) == rect.y
                    expect(rects[1].y) == rect.y + 3
                    expect(rects[2].y) == rect.y + 6
                    expect(rects[3].y) == rect.y + 9
                }
            }
        }
    }
}