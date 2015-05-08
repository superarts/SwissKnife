import UIKit

//	current you'll have to have UIApplicationMain(C_ARGC, C_ARGV, nil, NSStringFromClass(AppDelegate)) to successfully init the localized strings in storyboard
struct LTheme {
	struct localization {
		enum Language: String {
			case ChineseSimplified		= "zh-Hans"
			case ChineseTraditional		= "zh-Hant"
			case English				= "en"
			case EnglishAustralia		= "en-AU"
			case EnglishUnitedKingdom	= "en-UK"
			case EnglishUnitedStates	= "en-US"
			case French					= "fr"
			case Spanish				= "es"
			case SpanishMexico			= "es-MX"
		}
		static var language = Language(rawValue: NSLocale.preferredLanguages()[0] as String)
		static func language_reload() {
			language = Language(rawValue: NSLocale.preferredLanguages()[0] as String)
		}
		static var language_default: Language? = Language.English
		static var languages = [
			Language.English,
			Language.ChineseSimplified,
			Language.SpanishMexico,
		]
		static var languages_alias = [
			Language.EnglishAustralia.rawValue:			Language.English,
			Language.EnglishUnitedStates.rawValue:		Language.English,
			Language.EnglishUnitedKingdom.rawValue:		Language.English,
			Language.ChineseTraditional.rawValue:		Language.ChineseSimplified,
			Language.Spanish.rawValue:					Language.SpanishMexico,
		]
		static var languages_default = "en"
		static var strings: [String:[String]] = [
			"yes": [
				"Yes",
				"是",
				"Sí",
			],
			"no": [
				"No",
				"否",
				"No",
			],
		]
		class StringPack {
			var dictionary: [String:[String]] = [:]
			var auto_first_language: Bool = false
			init(auto: Bool = false) {
				//super.init()
				auto_first_language = auto
			}
			func append(key:String, _ value:String) {
				if var array = strings[key] {
					array.append(value)
					strings[key] = array
				} else {
					if auto_first_language {
						strings[key] = [key, value]
					} else {
						strings[key] = [value]
					}
				}
			}
		}
		static func strings_append(dict: [String:[String]]) {
			for (key, value) in dict {
				strings[key] = value
			}
		}
		static func string(key:String, index: Int? = nil) -> String {
			var i = index
			if i == nil {
				//	if system language is not supported, default language is used
				var lang: Language! = language
				if lang == nil {
					lang = language_default
				}
				if lang == nil {
					return key
				}
				i = find(languages, lang)

				//	if language is not supported directly, check alias
				if i == nil {
					if let lang = languages_alias[lang.rawValue] {
						i = find(languages, lang)
					}
				}
			}
			if i == nil {
				if language_default != nil {
					i = 0
				} else {
					return key
				}
			}
			if let array = strings[key] {
				if i < array.count {
					return array[i!]
				}
			}
			return key
		}

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
}

//	UIKit + Interface Builder: define various UIView properties in IB

//	TODO: add getters when extension property is added - having problem with associating in swift (key cannot be a string variable)
extension UIView {
	@IBInspectable var font_name: String? {
		get {
			if self is UILabel {
				let label = self as UILabel
				return label.font.fontName
			} else if self is UITextField {
				let field = self as UITextField
				return field.font.fontName
			} else if self is UITextView {
				let text = self as UITextView
				return text.font.fontName
			} else if self is UIButton {
				let button = self as UIButton
				return button.titleLabel!.font.fontName
			}
			return nil
		}
		set (name) {
			if self is UILabel {
				let label = self as UILabel
				label.font = UIFont(name: name!, size: label.font.pointSize)
			} else if self is UITextField {
				let field = self as UITextField
				field.font = UIFont(name: name!, size: field.font.pointSize)
			} else if self is UITextView {
				let text = self as UITextView
				text.font = UIFont(name: name!, size: text.font.pointSize)
			} else if self is UIButton {
				let button = self as UIButton
				button.titleLabel!.font = UIFont(name: name!, size: button.titleLabel!.font.pointSize)
			} else {
				LF.log("WARNING unknown type for font_name in Interface Builder", self)
			}
		}
	}
	@IBInspectable var enable_mask_circle: Bool {
		get {
			LF.log("WARNING no getter for UIView.enable_mask_circle")
			return false
		}
		set (enabled) {
			if Bool(enabled) == true {
				lf_enableBorder(is_circle: true)
			} else {
				layer.cornerRadius = 0
			}
		}
	}
	@IBInspectable var mask_radius: CGFloat {
		get {
			LF.log("WARNING no getter for UIView.mask_radius")
			return 0
		}
		set (f) {
			lf_enableBorder(radius: f)
		}
	}
	@IBInspectable var border_width: CGFloat {
		get {
			LF.log("WARNING no getter for UIView.mask_border")
			return 0
		}
		set (f) {
			lf_enableBorder(width: f)
		}
	}
	@IBInspectable var border_color: UIColor? {
		get {
			LF.log("WARNING no getter for UIView.mask_color")
			return nil
		}
		set (c) {
			lf_enableBorder(color: c)
		}
	}
}

extension UITextField {
	@IBInspectable var padding_left: CGFloat {
		get {
			LF.log("WARNING no getter for UITextField.padding_left")
			return 0
		}
		set (f) {
			layer.sublayerTransform = CATransform3DMakeTranslation(f, 0, 0)
		}
	}
}

extension UIScrollView {
	@IBInspectable var content_width: CGFloat {
		get {
			return content_w
		}
		set (f) {
			content_w = f
		}
	}
	@IBInspectable var content_height: CGFloat {
		get {
			return content_h
		}
		set (f) {
			content_h = f
		}
	}
}

extension UIBarItem {
	@IBInspectable var title_localized: String? {
		get {
			return self.title
		}
		set (s) {
			self.title = LTheme.localization.string(s!)
		}
	}
	@IBInspectable var auto_localized: Bool {
		get {
			return false
		}
		set (b) {
			if b {
				if let title = self.title {
					self.title = LTheme.localization.string(title)
				}
			}
		}
	}
}

extension UIButton {
	@IBInspectable var title_align_center: Bool {
		get {
			if let label = titleLabel {
				return label.textAlignment == .Center
			}
			return false
		}
		set (f) {
			if let label = titleLabel {
				label.textAlignment = .Center
			}
		}
	}
	@IBInspectable var highlighted_background_color: UIColor {
		get {
			return UIColor.blackColor()		//	TODO
		}
		set (color) {
			//let image = UIImage(CIImage: CIImage(color: CIColor(color: color)))	//why not working?
			let image = UIImage(color: color)
			setBackgroundImage(image, forState: .Highlighted)
		}
	}
	@IBInspectable var selected_background_color: UIColor {
		get {
			return UIColor.blackColor()		//	TODO
		}
		set (color) {
			let image = UIImage(color: color)
			setBackgroundImage(image, forState: .Selected)
		}
	}
	@IBInspectable var disabled_background_color: UIColor {
		get {
			return UIColor.blackColor()		//	TODO
		}
		set (color) {
			let image = UIImage(color: color)
			setBackgroundImage(image, forState: .Disabled)
		}
	}
}

extension UITextView {
	@IBInspectable var align_middle_vertical: Bool {
		get {
			return false	//	TODO
		}
		set (f) {
			self.addObserver(self, forKeyPath:"frame", options:.New, context:nil)
			self.addObserver(self, forKeyPath:"contentSize", options:.New, context:nil)
		}
	}
	/*
	@IBInspectable var placeholder: String {
		get {
            return associated(&LF.keys.text_placeholder) as String
		}
		set (s) {
			associate(&LF.keys.text_placeholder, object:s)
		}
	}
	*/
	override public func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject:AnyObject], context: UnsafeMutablePointer<Void>) {
		if let textView = object as? UITextView {
			var y: CGFloat = (textView.bounds.size.height - textView.contentSize.height * textView.zoomScale)/2.0;
			if y < 0 {
				y = 0
			}
			textView.content_y = -y
		}
	}
}

class LFAlertSegue: UIStoryboardSegue {
    override func perform() {
        let source = sourceViewController as UIViewController
        if let navigation = source.navigationController {
			let alert = UIAlertController(title: "Message", message: identifier, preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {
				(action: UIAlertAction!) -> Void in
			}))
			navigation.presentViewController(alert, animated: true, completion: nil)
            //navigation.pushViewController(destinationViewController as UIViewController, animated: false)
        }
    }
}

class LFActionSheetSegue: UIStoryboardSegue {
    override func perform() {
        let source = sourceViewController as UIViewController
        if let navigation = source.navigationController {
			let alert = UIAlertController(title: "Message", message: identifier, preferredStyle: .ActionSheet)
			alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {
				(action: UIAlertAction!) -> Void in
			}))
			navigation.presentViewController(alert, animated: true, completion: nil)
            //navigation.pushViewController(destinationViewController as UIViewController, animated: false)
        }
    }
}