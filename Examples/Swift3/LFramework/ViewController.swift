//
//  ViewController.swift
//  LFramework
//
//  Created by Leo on 12/19/2015.
//  Copyright (c) 2015 Leo. All rights reserved.
//

import UIKit
import SAKit
import CloudKit

class ViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
		SA.log("VIEW loaded")
		SA.dispatch_delay(0.25) {
			SA.log("0.25 sec")
		}
		SA.dispatch_delay(0.5) {
			SA.log("0.5 sec")
		}
		test()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	@IBAction func action_open_url() {
		UIApplication.open_string("http://www.google.com")
	}

	func test() {
		let rid = CKRecordID(recordName: "rid001")
		let noteRecord = CKRecord(recordType: "Notes", recordID: rid)
		noteRecord.setObject("word1" as CKRecordValue, forKey: "word")
		let container = CKContainer.default()
		container.discoverAllContactUserInfos() {
			(users, error) in
			print("users \(users)")
			print("error \(error)")
		}
		let privateDatabase = container.privateCloudDatabase
		privateDatabase.save(noteRecord, completionHandler: { (record, error) -> Void in
			if (error != nil) {
				print("failed \(error)")
			} else {
				print("saved \(record)")
			}
		})
	}
	func testFetch() {
		let container = CKContainer.default()
		let privateDatabase = container.privateCloudDatabase
		let predicate = NSPredicate(value: true)
		let query = CKQuery(recordType: "Notes", predicate: predicate)
		privateDatabase.perform(query, inZoneWith: nil) { (results, error) -> Void in
			if error != nil {
				print("failed \(error)")
			}
			else {
				print("results \(results)")
			}
		}
	}
}

//	LUser

/*
class LUserLocalizable: LFParseLocalizable {
	var username_too_short		= Item()
	var username_too_long		= Item()
	var invalid_email			= Item()
	var password_too_short		= Item()
	var password_too_long		= Item()
	var signing_up				= Item()
	var sign_up_successful		= Item()
	var sign_up_failed			= Item()
	var signing_in				= Item()
	var sign_in_successful		= Item()
	var sign_in_failed			= Item()
	var enter_your_email		= Item()
	var reset_password_title	= Item()
	var reset_password_desc		= Item()
	var reset_password_success	= Item()
	var reset_password_failed	= Item()
	var resetting_password		= Item()

	required init(dict: LTDictStrObj?) {
		super.init(dict: dict)
		username_too_short	+= "username too short"
		username_too_long	+= "username too long"
		invalid_email		+= "please enter a valid invalid email address"
		password_too_short	+= "password too short"
		password_too_long	+= "password too long"
		signing_up			+= "signing up..."
		sign_up_successful	+= "sign up successful"
		sign_up_failed		+= "sign up failed"
		signing_in			+= "signing in..."
		sign_in_successful	+= "sign in successful"
		sign_in_failed		+= "sign in failed"
		enter_your_email	+= "please enter your email"
		reset_password_title	+= "Reset Your Password"
		reset_password_desc		+= "Please enter your email address, and an email will be sent to you with a link that helps you reset your password."
		reset_password_success	+= "Password reset successful, please check your email inbox"
		reset_password_failed	+= "Password reset failed"
		resetting_password		+= "Resetting password..."

		username_too_short	+= "用户名过短"
		username_too_long	+= "用户名过长"
		invalid_email		+= "请输入正确的邮箱地址"
		password_too_short	+= "密码过长，请重试"
		password_too_long	+= "密码过短，请重试"
		signing_up			+= "正在注册……"
		sign_up_successful	+= "注册成功"
		sign_up_failed		+= "注册失败"
		signing_in			+= "正在登录……"
		sign_in_successful	+= "登录成功"
		sign_in_failed		+= "登录失败"
		enter_your_email	+= "请输入您的邮箱地址"
		reset_password_title	+= "重置密码"
		reset_password_desc		+= "请输入您的邮箱地址，您将会收到一封邮件。请点击其中的链接，并重置您的密码。"
		reset_password_success	+= "密码重置成功，请查看您的邮箱"
		reset_password_failed	+= "密码重置失败"
		resetting_password		+= "正在重置密码，请稍候……"
	}
}

struct LUser {
	typealias BlockVoidUser = ((PFUser?) -> Void)

	static let debug_force_appear = false
	static var current: PFUser?

	static let s = LUserLocalizable(publish:HM.is_publish)
	static var nav: LUNavMain!
	static var func_user: BlockVoidUser?

	static func present(controller: UIViewController, block: BlockVoidUser? = nil) {
		func_user = block
        if let user = PFUser.currentUser() where !debug_force_appear {
            current = user
			if let f = block {
				f(user)
			}
		} else {
			let sb = UIStoryboard(name: "LUser", bundle: nil)
			if let nav_main = sb.instantiateViewControllerWithIdentifier("LUNavMain") as? LUNavMain {
				controller.presentViewController(nav_main, animated:true, completion:nil)
				nav = nav_main
			}
		}
	}
	static func dismiss() {
		nav.lf_actionDismiss()
		if let f = func_user {
			f(current)
		}
	}
}

*/
