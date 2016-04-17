//: Playground - noun: a place where people can play

import Foundation

class TestObject: NSObject {
	var int0: Int = 0
	var int1: Int?
	var int2: Int!
	var int3: NSNumber?
	var str: String?
	
	func selectorTest() {
		print("responds to int0: \(respondsToSelector(NSSelectorFromString("int0")))")
		print("responds to int1: \(respondsToSelector(NSSelectorFromString("int1")))")
		print("responds to int2: \(respondsToSelector(NSSelectorFromString("int2")))")
		print("responds to int3: \(respondsToSelector(NSSelectorFromString("int3")))")
		print("responds to str: \(respondsToSelector(NSSelectorFromString("str")))")
		
		setValue(42, forKey:"int3")
	}
}

let test = TestObject()
test.selectorTest()
print("int3: \(test.int3)")
print("mirror: \(Mirror(reflecting: test).children.count)")

for property in Mirror(reflecting: test).children {
	print("property: \(property)")
}