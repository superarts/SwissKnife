struct LTest {
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

		var common = TestLocalizable(publish:false)
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
	}
}

class LFLocalizable: LFProfile {
	class Item: NSObject {
		var array = [String]()
		var str: String {
			if let index = LTheme.localization.language_current(index:nil) {
				return array[index]
			}
			return ""
		}
		var STR: String {
			return str.uppercaseString
		}
		var Str: String {
			let s = str
			return s[0].uppercaseString + s[1...s.length]
		}
	}
    override var dictionary: Dictionary<String, AnyObject> {
		var dict = [String: AnyObject]()
		for key in keys {
			if let item = valueForKey(key) as? Item {
				dict[key] = item.array
			}
		}
		return dict
	}
}

func += (inout left: LFLocalizable.Item, right: String) {
	left.array.append(right)
}

class TestLocalizable: LFLocalizable {
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
		LF.log("xx set", key)
		super.setValue(obj, forKey: key)
	}
	override func valueForKey(key: String) -> AnyObject? {
		LF.log("xx get", key)
		return super.valueForKey(key)
	}
	*/
}
