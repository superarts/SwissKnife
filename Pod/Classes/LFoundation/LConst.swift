import UIKit

public typealias LTDictStrObj = Dictionary<String, AnyObject>
public typealias LTDictStrStr = Dictionary<String, String>
public typealias LTArrayObj = Array<AnyObject>
public typealias LTArrayInt = Array<Int>
public typealias LTArrayStr = Array<String>
public typealias LTBlockVoid = (() -> Void)
public typealias LTBlockVoidError = ((NSError?) -> Void)
public typealias LTBlockVoidObjError = ((AnyObject?, NSError?) -> Void)
public typealias LTBlockVoidDict = ((LTDictStrObj?) -> Void)
public typealias LTBlockVoidDictError = ((LTDictStrObj?, NSError?) -> Void)
public typealias LTBlockVoidArray = ((LTArrayObj?) -> Void)
public typealias LTBlockVoidArrayError = ((LTArrayObj?, NSError?) -> Void)

struct LConst {
	static func color(name: String, alpha: CGFloat = 1) -> UIColor {
		if let rgb = LConst.rgb[name] {
			return UIColor(rgb: rgb, alpha: alpha)
		}
		return .clearColor()
	}
	static let rgb: [String:UInt] = [
		//	from: http://www.creepyed.com/2012/11/windows-phone-8-theme-colors-hex-rgb/
		"wp8-lime":		0xA4C400,
		"wp8-green":	0x60A917,
		"wp8-emerald":	0x008A00,
		"wp8-teal":		0x00ABA9,
		"wp8-cyan":		0x1BA1E2,
		"wp8-cobalt":	0x0050EF,
		"wp8-indigo":	0x6A00FF,
		"wp8-violet":	0xAA00FF,
		"wp8-pink":		0xF472D0,
		"wp8-magenta":	0xD80073,
		"wp8-crimson":	0xA20025,
		"wp8-red":		0xE51400,
		"wp8-orange":	0xFA6800,
		"wp8-amber":	0xF0A30A,
		"wp8-yellow":	0xE3C800,
		"wp8-brown":	0x825A2C,
		"wp8-olive":	0x6D8764,
		"wp8-steel":	0x647687,
		"wp8-mauve":	0x76608A,
		"wp8-taupe":	0x87794E,
		//	from: http://www.creepyed.com/2012/09/windows-8-colors-hex-code/
		"win8start-bg-0-1":	0xE064B7,
		"win8start-bg-0-2":	0xFF76BC,
		"win8start-bg-0-3":	0xDE4AAD,
		"win8start-bg-0-4":	0xE773BD,
		"win8start-bg-1-1":	0x2E1700,
		"win8start-bg-1-2":	0x632F00,
		"win8start-bg-1-3":	0x261300,
		"win8start-bg-1-4":	0x543A24,
		"win8start-bg-2-1":	0x2E1700,
		"win8start-bg-2-2":	0x632F00,
		"win8start-bg-2-3":	0x261300,
		"win8start-bg-2-4":	0x543A24,
		"win8start-bg-3-1":	0x4E0000,
		"win8start-bg-3-2":	0xB01E00,
		"win8start-bg-3-3":	0x380000,
		"win8start-bg-3-4":	0x61292B,
		"win8start-bg-4-1":	0x4E0038,
		"win8start-bg-4-2":	0xC1004F,
		"win8start-bg-4-3":	0x40002E,
		"win8start-bg-4-4":	0x662C58,
		"win8start-bg-5-1":	0x2D004E,
		"win8start-bg-5-2":	0x7200AC,
		"win8start-bg-5-3":	0x250040,
		"win8start-bg-5-4":	0x4C2C66,
		"win8start-bg-6-1":	0x1F0068,
		"win8start-bg-6-2":	0x4617B4,
		"win8start-bg-6-3":	0x180052,
		"win8start-bg-6-4":	0x423173,
		"win8start-bg-7-1":	0x001E4E,
		"win8start-bg-7-2":	0x006AC1,
		"win8start-bg-7-3":	0x001940,
		"win8start-bg-7-4":	0x2C4566,
		"win8start-bg-8-1":	0x004D60,
		"win8start-bg-8-2":	0x008287,
		"win8start-bg-8-3":	0x004050,
		"win8start-bg-8-4":	0x306772,
		"win8start-bg-9-1":	0x004A00,
		"win8start-bg-9-2":	0x199900,
		"win8start-bg-9-3":	0x003E00,
		"win8start-bg-9-4":	0x2D652B,
		"win8start-bg-10-1":	0x15992A,
		"win8start-bg-10-2":	0x00C13F,
		"win8start-bg-10-3":	0x128425,
		"win8start-bg-10-4":	0x3A9548,
		"win8start-bg-11-1":	0xE56C19,
		"win8start-bg-11-2":	0xFF981D,
		"win8start-bg-11-3":	0xC35D15,
		"win8start-bg-11-4":	0xC27D4F,
		"win8start-bg-12-1":	0xB81B1B,
		"win8start-bg-12-2":	0xFF2E12,
		"win8start-bg-12-3":	0x9E1716,
		"win8start-bg-12-4":	0xAA4344,
		"win8start-bg-13-1":	0xB81B6C,
		"win8start-bg-13-2":	0xFF1D77,
		"win8start-bg-13-3":	0x9E165B,
		"win8start-bg-13-4":	0xAA4379,
		"win8start-bg-14-1":	0x691BB8,
		"win8start-bg-14-2":	0xAA40FF,
		"win8start-bg-14-3":	0x57169A,
		"win8start-bg-14-4":	0x7F6E94,
		"win8start-bg-15-1":	0x1B58B8,
		"win8start-bg-15-2":	0x1FAEFF,
		"win8start-bg-15-3":	0x16499A,
		"win8start-bg-15-4":	0x6E7E94,
		"win8start-bg-16-1":	0x569CE3,
		"win8start-bg-16-2":	0x56C5FF,
		"win8start-bg-16-3":	0x4294DE,
		"win8start-bg-16-4":	0x6BA5E7,
		"win8start-bg-17-1":	0x00AAAA,
		"win8start-bg-17-2":	0x00D8CC,
		"win8start-bg-17-3":	0x008E8E,
		"win8start-bg-17-4":	0x439D9A,
		"win8start-bg-18-1":	0x83BA1F,
		"win8start-bg-18-2":	0x91D100,
		"win8start-bg-18-3":	0x7BAD18,
		"win8start-bg-18-4":	0x94BD4A,
		"win8start-bg-19-1":	0xD39D09,
		"win8start-bg-19-2":	0xE1B700,
		"win8start-bg-19-3":	0xC69408,
		"win8start-bg-19-4":	0xCEA539,
	]
}
