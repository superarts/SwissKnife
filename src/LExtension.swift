//	TODO: dependency
extension MBProgressHUD {
	class func show(title: String, view: UIView, duration: Float? = nil) {
		let hud = MBProgressHUD.showHUDAddedTo(view, animated: true) 
		hud.detailsLabelFont = UIFont.systemFontOfSize(18)
		hud.detailsLabelText = title
		if duration != nil {
			hud.mode = MBProgressHUDMode.Text
			hud.minShowTime = duration!
			hud.graceTime = duration!
			MBProgressHUD.hideAllHUDsForView(view, animated:true)
		}
	}
}

/*
//	parse: does it really make sense?
extension LFModel {
	func parse_upload() -> PFObject {
        var s = NSStringFromClass(self.dynamicType)
		s = s.stringByReplacingOccurrencesOfString(".", withString: "_", options:nil, range: nil)
		var pf = PFObject(className: s)
		LF.log("---- class", s)
		LF.log("---- class", self.id)
        for (key, value) in dictionary {
			if let array = value as? Array<AnyObject> {
				s = s.stringByAppendingFormat("%@: [\r", key)
				LF.log("array key", key)
				var array_pf: Array<AnyObject> = []
				for obj in array {
					LF.log("array value", obj)
					if obj is LFModel {
						let pf2 = obj.parse_upload()
						array_pf.append(pf2)
					} else {
						array_pf.append(parse_compatible(obj))
					}
				}
				pf.setObject(array_pf, forKey:key)
			/*
			} else if value is Int || value is Float {
				LF.log("number key", key)
				LF.log("number value", value)
				pf.setObject(value, forKey:key)
			*/
			} else {
				LF.log("obj key", key)
				LF.log("obj value", value)
				if value is LFModel {
					let pf2 = value.parse_upload()
					pf.setObject(pf2, forKey:key)
				} else {
					pf.setObject(parse_compatible(value), forKey:key)
				}
			}
        }
		var error: NSError?
		let result = pf.save(&error)
		LF.log("----", error)
		return pf
	}
	func parse_compatible(obj: AnyObject) -> AnyObject {
		if obj is UIColor {
			return "TODO:UIColor"
		}
		return obj
	}
}
*/


