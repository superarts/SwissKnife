import Nimble
import Quick
import SwissKnifeCore
import SwissKnifeCoreFoundation

class DateTimeUtilitySpec: QuickSpec, DateTimeUtilityRequired {
    override func spec() {
        context("dependency") {
            describe("injection") {
                it("should not be nil") {
                    expect(self.dateTimeUtility).toNot(beNil())
                }
            }
        }
        context("convert") {
            describe("rfc1123") {
                it("should be nil") {
                    let str = "invalid"
                    expect(self.dateTimeUtility.toDate(string: str, format: .rfc1123)).to(beNil())
                }
                it("should not be nil") {
                    let str = "Thu, 30 Nov 2023 03:00:00 GMT"
                    expect(self.dateTimeUtility.toDate(string: str, format: .rfc1123)).toNot(beNil())
                }
            }
        }
    }
}