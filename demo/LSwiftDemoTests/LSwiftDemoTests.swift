import UIKit
import XCTest

class LSwiftDemoTests: XCTestCase {
   
    override func setUp() {
		LF.log("iOS version", UIDevice.currentDevice().systemVersion)
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
        XCTAssert(UIDevice.version_at_least("7.0.0"), "Pass")
        XCTAssert(UIDevice.version_at_least("8.0.0"), "Pass")
        XCTAssert(UIDevice.version_at_least("8.4.0"), "Pass")
        XCTAssert(!UIDevice.version_at_least("8.5.0"), "Pass")
        XCTAssert(!UIDevice.version_at_least("9.0.0"), "Pass")
    }
   
	/*
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
	*/
    
}
