//
//  ViewController.swift
//  LFramework2
//
//  Created by Leo on 12/19/2015.
//  Copyright (c) 2015 Leo. All rights reserved.
//

import UIKit
import LFramework2

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		LF.log("VIEW loaded")
		LF.dispatch_delay(0.25) {
			LF.log("0.25 sec")
		}
		LF.dispatch_delay(0.5) {
			LF.log("0.5 sec")
		}
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	@IBAction func action_open_url() {
		UIApplication.open_string("http://www.google.com")
	}
}
