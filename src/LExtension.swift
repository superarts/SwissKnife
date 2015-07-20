extension MBProgressHUD {
	class func show(title: String, view: UIView, duration: Float? = nil) -> MBProgressHUD {
		let hud = MBProgressHUD.showHUDAddedTo(view, animated: true) 
		hud.detailsLabelFont = UIFont.systemFontOfSize(18)
		hud.detailsLabelText = title
		if duration != nil {
			hud.mode = MBProgressHUDMode.Text
			hud.minShowTime = duration!
			hud.graceTime = duration!
			MBProgressHUD.hideAllHUDsForView(view, animated:true)
		}
        return hud
	}
}

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
