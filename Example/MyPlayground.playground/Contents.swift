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

class ChildObject: TestObject {
	var int10: Int = 0
	var int11: Int?
	var str10: String = "test"
	var str11: String?
	
	func test() {
        var array = [String]()
        var count: CUnsignedInt = 0
		let properties: UnsafeMutablePointer<objc_property_t> = class_copyPropertyList(object_getClass(self), &count)

  /*
		var c: AnyClass! = object_getClass(self)
		loop: while c != nil {
			print("class: \(NSStringFromClass(c))")
			if NSStringFromClass(c) == "NSObject" {
				break
			}
			var ct: CUnsignedInt = 0
			let prop: UnsafeMutablePointer<objc_property_t> = class_copyPropertyList(c, &ct)
			for i in 0 ..< Int(ct) {
                if let key = NSString(CString: property_getName(prop[i]), encoding: NSUTF8StringEncoding) {
    				if let value: AnyObject? = valueForKey(key as String) where key != "raw" {
						print("key: \(key), value: \(value)")
						array.append(key as String)
    				}
                }
			}
			c = class_getSuperclass(c)
		}
*/
        for i in 0 ..< Int(count) {
            if let key = NSString(CString: property_getName(properties[i]), encoding: NSUTF8StringEncoding) as? String {
				//LF.log(key, valueForKey(key))
 				//if let _ = valueForKey(key) {
					array.append(key)
				//}
			}
        }
		print("keys: \(array)")
	}
}

let child = ChildObject()
child.test()

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