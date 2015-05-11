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

extension LTheme.localization {
	static func test() {
		//	default language from system settings
		LF.log("language", LTheme.localization.language?.rawValue)
		LF.log("test 1", LTheme.localization.string("yes"))
		LF.log("test 2", LTheme.localization.string("na"))

		//	set language to a supported language
		LTheme.localization.language = .SpanishMexico
		LF.log("")
		LF.log("test 1", LTheme.localization.string("yes"))
		LF.log("test 2", LTheme.localization.string("na"))

		//	set language to a language that is not supported (default language is english)
		LTheme.localization.language = .French
		LF.log("")
		LF.log("test 1", LTheme.localization.string("yes"))
		LF.log("test 2", LTheme.localization.string("na"))

		//	no default language - use default language as fallback
		LTheme.localization.language = nil
		LF.log("")
		LF.log("test 1", LTheme.localization.string("yes"))
		LF.log("test 2", LTheme.localization.string("na"))

		//	disable default language - keys are used instead
		LTheme.localization.language_default = nil
		LF.log("")
		LF.log("test 1", LTheme.localization.string("yes"))
		LF.log("test 2", LTheme.localization.string("na"))

		//	set language index manually
		LF.log("")
		LF.log("test 1", LTheme.localization.string("yes", index:2))
		LF.log("test 2", LTheme.localization.string("na", index:999))

		//	define a new string pack manually
		var set0 = [
			"good": [
				"Good",
				"好",
				"Bien",
			],
			"bad": [
				"Bad",
				"坏",
				"Mal",
			],
		]
		//	or use helper class

		//	split by meanings, good for translators who know different languages
		var set1 = LTheme.localization.StringPack()
		set1.append("big", "Big")
		set1.append("big", "大")
		set1.append("big", "Grande")
		set1.append("small", "Small")
		set1.append("small", "小")
		set1.append("small", "Pequeño")

		//	split by languages, good for translators to work separately
		var set2 = LTheme.localization.StringPack()
		set2.append("new", "New")
		set2.append("old", "Old")
		set2.append("new", "新")
		set2.append("old", "旧")
		set2.append("new", "Nuevo")
		set2.append("old", "Viejo")

		//	load new string sets
		LTheme.localization.strings_append(set0)
		LTheme.localization.strings_append(set1.dictionary)
		LTheme.localization.strings_append(set2.dictionary)
		LTheme.localization.language_reload()
		LF.log("")
		LF.log("test 1", LTheme.localization.string("good"))
		LF.log("test 2", LTheme.localization.string("bad"))
		LF.log("test 3", LTheme.localization.string("big"))
		LF.log("test 4", LTheme.localization.string("small"))
		LF.log("test 5", LTheme.localization.string("new"))
		LF.log("test 6", LTheme.localization.string("old"))
		LF.log("test x", LTheme.localization.string("wow"))
	}
}
