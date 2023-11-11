//
//  AppDelegate.swift
//  LFramework
//
//  Created by Leo on 12/19/2015.
//  Copyright (c) 2015 Leo. All rights reserved.
//

import UIKit
import SAKit
import EVReflection

class UserModel: SAModel {
	var name: String?
	var friends: [UserModel] = []
	var father: UserModel!
	/*
	required init(dict: LTDictStrObj?) {
		super.init(dict: dict)
		reload("father", type: NSStringFromClass(UserModel))
		reload("friends", type: NSStringFromClass(UserModel))
	}
	*/
}

class UserObject: EVObject {
    var id: Int = 0
    var name: String = ""
    var friends: [UserObject]? = []
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		SA.log("APP launched")

		let model = UserModel(dict: [
			"id": 42 as AnyObject, 
			"name": "Leah Cain" as AnyObject, 
			//"friends": [["id": 43, "name": "Leo"]],
			//"father": ["id": 44, "name": "Deckard Cain"],
		])
		SA.log("model", model)
		//reflect(model)
		
		let json:String = "{\"id\": 24, \"name\": \"Bob Jefferson\", \"friends\": [{\"id\": 29, \"name\": \"Jen Jackson\"}]}"
		let user = UserObject(json: json)
		print("user: \(user)")
		print("\(Bundle(for: type(of: model)))")
		let bundle = Bundle(for: type(of: model))
		if let name = bundle.infoDictionary?[kCFBundleNameKey as String] as? String {
			//let appName = name.characters.split(separator: {$0 == "."}).map({ String($0) }).last ?? ""
			//print(appName)
		}

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}
