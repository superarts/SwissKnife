struct LTest {
	static func profile() {
		LF.log("url root", Test.profile.url.root)
		LF.log("api list", Test.profile.api.list)
	}
	static func localization() {
		//	default language from system settings
		LF.log("language", LTheme.localization.language?.rawValue)
		LF.log("test 1", LTheme.localization.Str("yes"))
		LF.log("test 2", LTheme.localization.Str("na"))

		//	set language to a supported language
		LTheme.localization.language = .SpanishMexico
		LF.log("")
		LF.log("test 1", LTheme.localization.Str("yes"))
		LF.log("test 2", LTheme.localization.Str("na"))

		//	set language to a language that is not supported (default language is english)
		LTheme.localization.language = .French
		LF.log("")
		LF.log("test 1", LTheme.localization.Str("yes"))
		LF.log("test 2", LTheme.localization.Str("na"))

		//	no default language - use default language as fallback
		LTheme.localization.language = nil
		LF.log("")
		LF.log("test 1", LTheme.localization.Str("yes"))
		LF.log("test 2", LTheme.localization.Str("na"))

		//	disable default language - keys are used instead
		LTheme.localization.language_default = nil
		LF.log("")
		LF.log("test 1", LTheme.localization.Str("yes"))
		LF.log("test 2", LTheme.localization.Str("na"))

		//	set language index manually
		LF.log("")
		LF.log("test 1", LTheme.localization.Str("yes", index:2))
		LF.log("test 2", LTheme.localization.Str("na", index:999))

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

		/*
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
		*/
		LTheme.localization.strings_append(set0)

		var common = Test.localizable.common
		LTheme.localization.strings_append(common.dictionary)
		LF.log("localizable", common.keys)

		LTheme.localization.language_default = .SpanishMexico
		LF.log("")
		LF.log("test 1", LTheme.localization.Str("good"))
		LF.log("test 2", LTheme.localization.Str("bad"))
		LF.log("test 3", LTheme.localization.Str("big"))
		LF.log("test 4", LTheme.localization.Str("small"))
		LF.log("Test 5", LTheme.localization.Str("new"))
		LF.log("Test 6", LTheme.localization.Str("old"))
		LF.log("test x", LTheme.localization.Str("wow"))

		LF.log("test 7", LTheme.localization.str("new"))
		LF.log("TEST 7", LTheme.localization.STR("old"))

		LF.log("test 8 array", common.new.array)
		LF.log("test 8", common.new.str)
		LF.log("Test 8", common.new.Str)
		LF.log("TEST 8", common.new.STR)
		LF.log("Test 8", common.old.Str)
		LTheme.localization.language_default = .English
	}
}

class TestLocalizable: LFParseLocalizable {
	var new = Item()
	var old = Item()
	required init(dict: LTDictStrObj?) {
		super.init(dict: dict)
		new += "new"
		new += "新"
		new += "nuevo"
		old += "old"
		old += "旧"
		old += "viejo"
	}
	/*
	override func setValue(obj: AnyObject?, forKey key: String) {
		super.setValue(obj, forKey: key)
	}
	override func valueForKey(key: String) -> AnyObject? {
		return super.valueForKey(key)
	}
	*/
}

class TestProfileURL: LFProfile {
	var root = "http://na.com"
	var promotion = "http://nb.com"
}
class TestProfileAPI: LFProfile {
	var list = "v1/list"
	var detail = "v1/detail"
}

struct Test {
	struct profile {
		static let is_publisher = false
		static var url = TestProfileURL(publish:is_publisher)
		static var api = TestProfileAPI(publish:is_publisher)
	}
	struct localizable {
		static var common = TestLocalizable(publish:false)
	}
}
