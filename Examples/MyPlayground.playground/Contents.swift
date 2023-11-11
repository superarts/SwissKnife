//: Playground - noun: a place where people can play

import Foundation

class BaseObject: NSObject {
	var intBase: Int = 0
}

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

class ChildObject: TestObject {
	var int10: Int = 0
	var int11: Int?
	var str10: String = "test"
	var str11: String?
	
	func keys() -> [String] {
        var array = [String]()

		var c: AnyClass! = object_getClass(self)
		loop: while c != nil {
			print("class: \(NSStringFromClass(c))")
			if NSStringFromClass(c) == "NSObject" {
				break
			}
			var count: CUnsignedInt = 0
			let properties: UnsafeMutablePointer<objc_property_t> = class_copyPropertyList(c, &count)
			for i in 0 ..< Int(count) {
                if let key = NSString(CString: property_getName(properties[i]), encoding: NSUTF8StringEncoding) {
					array.append(key as String)
                }
			}
			c = class_getSuperclass(c)
		}
		return array
	}
}

let child = ChildObject()
print("keys: \(child.keys())")

/*
let test = TestObject()
test.selectorTest()
print("int3: \(test.int3)")
print("mirror: \(Mirror(reflecting: test).children.count)")

for property in Mirror(reflecting: test).children {
	print("property: \(property)")
}
*/

for property in Mirror(reflecting: child).children {
	print("property: \(property)")
}
if let superMirror = Mirror(reflecting: child).superclassMirror() {
    for property in superMirror.children {
    	print("super property: \(property)")
    }
}

var mirror: Mirror? = Mirror(reflecting: child)
repeat {
    for property in mirror!.children {
    	print("property: \(property)")
    }
	mirror = mirror?.superclassMirror()
} while mirror != nil
