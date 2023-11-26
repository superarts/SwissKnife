import Nimble
import Quick
import SwissKnifeCore
import SwissKnifeCoreFoundation

class StringUtilitySpec: QuickSpec, StringUtilityRequired {
    override func spec() {
        context("dependency") {
            describe("injection") {
                it("should not be nil") {
                    expect(self.stringUtility).toNot(beNil())
                }
            }
        }
        context("matches") {
            describe("success") {
                it("should match") {
                    expect(self.stringUtility.matches("test1", pattern: "test")).to(beTrue())
                    // expect(self.stringUtility.matches("test", pattern: "$\\w+^")).to(beTrue())
                }
            }
            describe("failure") {
                it("should not match") {
                    expect(self.stringUtility.matches("test1", pattern: "Test")).to(beFalse())
                    expect(self.stringUtility.matches("test1", pattern: "$\\w^")).to(beFalse())
                }
                it("is invalid regex") {
                    expect(self.stringUtility.matches("test1", pattern: "[")).to(beFalse())
                }
            }
        }
        context("captured") {
            describe("success") {
                it("should capture the first") {
                    expect(self.stringUtility.captured("test1 test2", pattern: "(\\w+)").first).to(equal("test1"))
                }
            }
            describe("failure") {
                it("should return nil for invalid pattern") {
                    expect(self.stringUtility.captured("test1 test2", pattern: "\\").first).to(beNil())
                }
                it("should return nil pattern is not found") {
                    expect(self.stringUtility.captured("test1 test2", pattern: "test3").first).to(beNil())
                }
                it("is invalid regex") {
                    expect(self.stringUtility.captured("test1 test2", pattern: "[").first).to(beNil())
                }
            }
        }
        context("groups") {
            describe("success") {
                it("should capture groups") {
                    expect(try self.stringUtility.groups("test1 test2", pattern: "(\\w+)").count).to(equal(2))
                }
            }
            describe("failure") {
                it("should throw for invalid pattern") {
                    expect(try self.stringUtility.groups("test1 test2", pattern: "\\").count).to(throwError())
                }
            }
        }
        context("trim") {
            describe("success") {
                it("should capture groups") {
                    expect(self.stringUtility.trimAllWhitespaces(" 1 \n 2 \n 3 ")).to(equal("1\n2\n3"))
                }
            }
        }
        context("TerminalColor") {
            describe("success") {
                it("should capture groups") {
                    expect(TerminalColor.red.string).toNot(beNil())
                }
            }
        }
        context("lines") {
            describe("success") {
                it("should work for 1") {
                    let s = "0\n1\n2\n3\n4\n5\n6"
                    expect(self.stringUtility.linesOf(string: s, range: 0 ..< 1)).to(equal("0\n"))
                }
                it("should work for 2") {
                    let s = "0\n1\n2\n3\n4\n5\n6"
                    expect(self.stringUtility.linesOf(string: s, range: 0 ..< 2)).to(equal("0\n1\n"))
                }
                it("should work from 1") {
                    let s = "0\n1\n2\n3\n4\n5\n6"
                    expect(self.stringUtility.linesOf(string: s, range: 1 ..< 3)).to(equal("1\n2\n"))
                }
                it("should work with blank lines") {
                    let s = "0\n1\n\n3\n4\n5\n6"
                    expect(self.stringUtility.linesOf(string: s, range: 1 ..< 3)).to(equal("1\n\n"))
                }
            }
        }
        context("remove duplicated lines") {
            describe("success") {
                it("should maintain order") {
                    expect(self.stringUtility.removeDuplicatedLines("1\n2\n2\n3\n3")).to(equal("1\n2\n3"))
                    expect(self.stringUtility.removeDuplicatedLines("1\n2\n3\n3\n2")).to(equal("1\n2\n3"))
                }
                it("should handle one line strings") {
                    expect(self.stringUtility.removeDuplicatedLines("")).to(equal(""))
                    expect(self.stringUtility.removeDuplicatedLines("1")).to(equal("1"))
                }
            }
        }
    }
}