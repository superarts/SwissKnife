import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		init_parse()
		LTest.localization()
        return true
    }
	func init_parse() {
		let applicationId	= "C4MCodjI5pFuctdLMDKSjgGSybVm9XWLFc7cmDQF"
		let clientKey		= "ik5E1yuhvPwUqiUBc6QyhSN3NSz3KyQmLWtOWHWw"
		Parse.setApplicationId(applicationId, clientKey:clientKey)

		PFUser.enableAutomaticUser()
		LF.log("user", PFUser.currentUser())
		/*
		PFCloud.callFunctionInBackground("test_hello", withParameters:[:], block:{
			(object: AnyObject!, error: NSError!) -> Void in
			LF.log("parse", object)
		}) 
		*/
		//PFQuery.clearAllCachedResults()
	}

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
    }
}

