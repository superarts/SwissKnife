import Foundation
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
            describe("other") {
                it("should be nil") {
                    let str = "invalid"
                    expect(self.dateTimeUtility.toDate(string: str, format: .other(format: "na"))).to(beNil())
                }
                it("should not be nil") {
                    let str = "112233"
                    let date = self.dateTimeUtility.toDate(string: str, format: .other(format: "hhmmss"))
                    print("DEBUG other date 112233 w/ hhmmss: \(date ?? Date())")
                    expect(date).toNot(beNil())
                }
            }
        }
    }
}