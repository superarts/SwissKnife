import Nimble
import Quick
import SwissKnifeCore

private enum Direction: String, CaseIterable, IteratedCaseMatchable {
    case north, south, east, west
}

class IteratedCaseMatchableSpec: QuickSpec {
    override func spec() {
        context("IteratedCaseMatchable") {
            describe("isContained") {
                it("should match") {
                    expect(Direction.isContained(by: "When you are not sure, always go west.")).to(beTrue())
                }
                it("should not match") {
                    expect(Direction.isContained(by: "Up is not a direction on the compass.")).to(beFalse())
                }
            }
            describe("firstStringContained") {
                it("should match") {
                    expect(Direction.firstStringContained(by: "When you are not sure, always go west.")).to(equal("west"))
                }
                it("should not match") {
                    expect(Direction.firstStringContained(by: "Up is not a direction on the compass.")).to(beNil())
                }
            }
        }
    }
}