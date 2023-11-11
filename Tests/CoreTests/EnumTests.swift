import Nimble
import Quick
import SwissKnife

private enum Direction: String, CaseIterable, IteratedCaseMatchable {
    case north, south, east, west
}

class EnumSpec: QuickSpec {
    override func spec() {
        context("Enumerations") {
            describe("IteratedCaseMatchable") {
                it("should match") {
                    expect(Direction.isContained(by: "When you are not sure, always go west.")).to(beTrue())
                }
                it("should not match") {
                    expect(Direction.isContained(by: "Up is not a direction on compass.")).to(beFalse())
                }
            }
        }
    }
}