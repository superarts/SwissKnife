//
//  ExampleTests.swift
//  ExampleTests
//
//  Created by Leo Liu on 4/3/17.
//  Copyright © 2017 Bamtboo. All rights reserved.
//

import XCTest
@testable import Example
@testable import SAKit

class ExampleTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
		XCTAssertEqual(SA.log("test", "test1", 42, nil, "test2"), "test: \"test1\", 42, nil, \"test2\"", "logging with multiple parameters")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}