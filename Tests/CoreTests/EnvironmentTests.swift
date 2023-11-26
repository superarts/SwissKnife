import Nimble
import Quick
import SwissKnife

class EnvironmentSpec: QuickSpec, EnvironmentRequired {
    override func spec() {
        context("Environment") {
            describe("CLI") {
                it("should be debug") {
                    expect(self.environment.isDebug).to(beTrue())
                }
                it("should not be release") {
                    expect(self.environment.isRelease).to(beFalse())
                }
            }
        }
    }
}
