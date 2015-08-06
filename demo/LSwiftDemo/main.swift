import UIKit

class LSDemoLocalizable: LFLocalizable {
	var test = Item()
	var test2 = Item()
	required init(dict: LTDictStrObj?) {
		super.init(dict: dict)
		test += "test I"
		test += "测试 I"
		test += "prueba I"
		test2 += "test II"
		test2 += "测试 II"
		test2 += "prueba II"
	}
}

struct LS {
	static let is_publish = true
	static let demo = LSDemoLocalizable(publish:is_publish)
}

//	init parse
let applicationId	= "C4MCodjI5pFuctdLMDKSjgGSybVm9XWLFc7cmDQF"
let clientKey		= "ik5E1yuhvPwUqiUBc6QyhSN3NSz3KyQmLWtOWHWw"
Parse.setApplicationId(applicationId, clientKey:clientKey)
PFUser.enableAutomaticUser()

//	load localizable - to support storyboard
LTheme.localization.strings_append(LS.demo.dictionary)

UIApplicationMain(Process.argc, Process.unsafeArgv, nil, NSStringFromClass(AppDelegate))
