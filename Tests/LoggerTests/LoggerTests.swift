import Nimble
import Quick
import SwissKnifeLogger

private enum Module: String, RawRepresentable {
    case test1
    case test2
}

class LoggerSpec: QuickSpec, Loggable {
    override func spec() {
        context("log") {
            describe("module") {
                it("should log") {
                    LoggerManager.shared.supportedModules = [Module.test1]
                    let result = self.log(Module.test1, "DEBUG message 1")
                    expect(result).to(equal("[test1] DEBUG message 1"))
                }
                it("should not log") {
                    LoggerManager.shared.supportedModules = [Module.test1]
                    let result = self.log(Module.test2, "DEBUG message 1")
                    expect(result).to(beNil())
                }
            }
        }
    }
}
