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
		static var language = Language(rawValue: NSLocale.preferredLanguages()[0] )
		static func language_reload() {
			language = Language(rawValue: NSLocale.preferredLanguages()[0] )
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
		/*
		class StringPack {
			var dictionary: [String:[String]] = [:]
			var auto_first_language: Bool = false
			init(auto: Bool = false) {
				//super.init()
				auto_first_language = auto
			}
			func append(key:String, _ value:String) {
				if var array = dictionary[key] {
					array.append(value)
					dictionary[key] = array
				} else {
					if auto_first_language {
						dictionary[key] = [key, value]
					} else {
						dictionary[key] = [value]
					}
				}
			}
		}
		*/
		static func strings_append(dict: LTDictStrObj) {//[String:[String]]) {
			for (key, value) in dict {
				if let dict = value as? [String] {
					strings[key] = dict
				}
			}
		}
		static func language_current(index: Int? = nil) -> Int? {
			var i = index
			if i == nil {
				//	if system language is not supported, default language is used
				var lang: Language! = language
				if lang == nil {
					lang = language_default
				}
				if lang == nil {
					return nil
				}
				i = languages.indexOf(lang)

				//	if language is not supported directly, check alias
				if i == nil {
					if let lang = languages_alias[lang.rawValue] {
						i = languages.indexOf(lang)
					}
				}
			}
			if i == nil && language_default != nil {
				i = 0
			}
			return i
		}
		static func STR(key:String, index: Int? = nil) -> String {
			return str(key, index:index).uppercaseString
		}
		static func Str(key:String, index: Int? = nil) -> String {
			let s = str(key, index:index)
			return s[0].uppercaseString + s[1...s.length]
		}
		static func str(key:String, index: Int? = nil) -> String {
			/*
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
			*/
			if let i = language_current(index) {
				if let array = strings[key] where i < array.count {
					return array[i]
				}
			}
			return key
		}
	}
}

//	UIKit + Interface Builder: define various UIView properties in IB

extension UITabBarController {
	@IBInspectable var selected_index: Int {
		get {
			return selectedIndex
		}
		set(index) {
			selectedIndex = index
		}
	}
}

extension UIView {
	//	TODO: add getters when extension property is added - having problem with associating in swift (key cannot be a string variable)
	//	WARNING: font_name of UIView will be deprecated soon, use text_font_name etc. instead.
	@IBInspectable var font_name: String? {
		get {
			if self is UILabel {
				let label = self as! UILabel
				return label.font.fontName
			} else if self is UITextField {
				let field = self as! UITextField
				return field.font?.fontName
			} else if self is UITextView {
				let text = self as! UITextView
				return text.font?.fontName
			} else if self is UIButton {
				let button = self as! UIButton
				return button.titleLabel!.font.fontName
			}
			return nil
		}
		set (name) {
			if self is UILabel {
				let label = self as! UILabel
				label.font = UIFont(name: name!, size: label.font.pointSize)
			} else if self is UITextField {
				let field = self as! UITextField
				field.font = UIFont(name: name!, size: field.font!.pointSize)
			} else if self is UITextView {
				let text = self as! UITextView
				text.font = UIFont(name: name!, size: text.font!.pointSize)
			} else if self is UIButton {
				let button = self as! UIButton
				button.titleLabel!.font = UIFont(name: name!, size: button.titleLabel!.font.pointSize)
			} else if self is UISegmentedControl {
				let segment = self as! UISegmentedControl
				var font_size: CGFloat = 13
				if let attr = segment.titleTextAttributesForState(.Normal), let font = attr[NSFontAttributeName] as? UIFont {
					font_size = font.pointSize
				}
				let attr = [NSFontAttributeName: UIFont(name: name!, size: font_size)!]
				segment.setTitleTextAttributes(attr, forState: .Normal)
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
				enable_border(is_circle: true)
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
			enable_border(radius: f)
		}
	}
	@IBInspectable var border_width: CGFloat {
		get {
			LF.log("WARNING no getter for UIView.border_width")
			return 0
		}
		set (f) {
			enable_border(width: f)
		}
	}
	@IBInspectable var border_color: UIColor? {
		get {
			LF.log("WARNING no getter for UIView.border_color")
			return nil
		}
		set (c) {
			enable_border(color: c)
		}
	}
	@IBInspectable var gradient_top: UIColor? {
		get {
			LF.log("WARNING no getter for UIView.gradient_top")
			return nil
		}
		set (c) {
			insert_gradient([c, backgroundColor], 
					point1:CGPointMake(0, 0),
					point2:CGPointMake(0, 1))
		}
	}
	@IBInspectable var shadow_down: CGFloat {
		get {
			LF.log("WARNING no getter for UIView.shadow_down")
			return 0
		}
		set (f) {
            LF.dispatch_delay(0.1, {
                self.add_shadow(CGSizeMake(0, f))
            })
		}
	}
}

extension UILabel {
	@IBInspectable var text_localized: String? {
		get {
			return self.text
		}
		set (s) {
			self.text = LTheme.localization.Str(s!)
		}
	}
	@IBInspectable var text_auto_localized: Bool {
		get {
			LF.log("WARNING: getter not implemented")
			return false
		}
		set (b) {
			if b {
				if let text = self.text {
					self.text = LTheme.localization.Str(text)
				}
			}
		}
	}
	@IBInspectable var text_font_name: String? {
		get {
			return font.fontName
		}
		set (name) {
			font = UIFont(name: name!, size: font.pointSize)
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
	@IBInspectable var text_localized: String? {
		get {
			return self.text
		}
		set (s) {
			self.text = LTheme.localization.Str(s!)
		}
	}
	@IBInspectable var text_auto_localized: Bool {
		get {
			LF.log("WARNING: getter not implemented")
			return false
		}
		set (b) {
			if b {
				if let text = self.text {
					self.text = LTheme.localization.Str(text)
				}
			}
		}
	}
	@IBInspectable var text_font_name: String? {
		get {
			return font?.fontName
		}
		set (name) {
			font = UIFont(name: name!, size: font!.pointSize)
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
			self.title = LTheme.localization.Str(s!)
		}
	}
	@IBInspectable var auto_localized: Bool {
		get {
			return false
		}
		set (b) {
			if b {
				if let title = self.title {
					self.title = LTheme.localization.Str(title)
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
	//	TODO: @IBInspectable var selected_title_localized: String? { }
	@IBInspectable var normal_title_localized: String? {
		get {
			return titleForState(.Normal)
		}
		set (s) {
			setTitle(LTheme.localization.Str(s!), forState:.Normal)
		}
	}
	@IBInspectable var normal_text_auto_localized: Bool {
		get {
			LF.log("WARNING: getter not implemented")
			return false
		}
		set (b) {
			if b {
				if let title = titleForState(.Normal) {
					setTitle(LTheme.localization.Str(title), forState:.Normal)
				}
			}
		}
	}
	@IBInspectable var highlighted_title_localized: String? {
		get {
			return titleForState(.Highlighted)
		}
		set (s) {
			setTitle(LTheme.localization.Str(s!), forState:.Highlighted)
		}
	}
	@IBInspectable var highlighted_text_auto_localized: Bool {
		get {
			LF.log("WARNING: getter not implemented")
			return false
		}
		set (b) {
			if b {
				if let title = titleForState(.Highlighted) {
					setTitle(LTheme.localization.Str(title), forState:.Highlighted)
				}
			}
		}
	}
	@IBInspectable var label_font_name: String? {
		get {
			if let label = titleLabel {
				return label.font.fontName
			}
			return nil
		}
		set (name) {
			if let label = titleLabel {
				label.font = UIFont(name: name!, size: label.font.pointSize)
			}
		}
	}
}

extension UITextView {
	@IBInspectable var align_middle_vertical: Bool {
		get {
			return false	//	TODO
		}
		set (b) {
			if b {
				self.addObserver(self, forKeyPath:"frame", options:.New, context:nil)
				self.addObserver(self, forKeyPath:"contentSize", options:.New, context:nil)
			}
		}
	}
	@IBInspectable var placeholder: String {
		get {
            return associated(&LF.keys.text_placeholder) as! String     //  TODO: make sure it's nil.. for now
		}
		set (s) {
			associate(&LF.keys.text_placeholder, object:s)
			//associate(&LF.keys.text_color, object:textColor!)
			self.text = s
			//NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("lf_text_changed:"), name:UITextViewTextDidChangeNotification, object: nil);
			NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("lf_text_edit_began:"), name:UITextViewTextDidBeginEditingNotification, object: nil);
			NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("lf_text_edit_ended:"), name:UITextViewTextDidEndEditingNotification, object: nil);
		}
	}

	//	observers should be removed manually. TODO: find a better solution
	func remove_observer_alignment() {
		//NSNotificationCenter.defaultCenter().removeObserver(self)
		self.removeObserver(self, forKeyPath:"frame")
		self.removeObserver(self, forKeyPath:"contentSize")
	}
	func remove_observer_placeholder() {
		//NSNotificationCenter.defaultCenter().removeObserver(self, name:UITextViewTextDidChangeNotification, object: nil);
		NSNotificationCenter.defaultCenter().removeObserver(self, name:UITextViewTextDidBeginEditingNotification, object: nil);
		NSNotificationCenter.defaultCenter().removeObserver(self, name:UITextViewTextDidEndEditingNotification, object: nil);
	}

	override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String:AnyObject]?, context: UnsafeMutablePointer<Void>) {
		if let _ = object as? UITextView {
			lf_reload_align_middle_vertical()
		}
	}
	func lf_reload_align_middle_vertical() {
		var y: CGFloat = (self.bounds.size.height - self.contentSize.height * self.zoomScale)/2.0;
		if y < 0 {
			y = 0
		}
		self.content_y = -y
	}
	//func lf_text_changed(notification: NSNotification) { }
	func lf_text_edit_began(notification: NSNotification) {
		if self.text == self.placeholder {
			self.text = ""
            //self.textColor = associated(&LF.keys.text_color) as? UIColor
		}
	}
	func lf_text_edit_ended(notification: NSNotification) {
		if self.text == "" {
			self.text = self.placeholder
            //self.textColor = .grayColor()
		}
	}
	@IBInspectable var text_localized: String? {
		get {
			return self.text
		}
		set (s) {
			self.text = LTheme.localization.Str(s!)
		}
	}
	@IBInspectable var text_auto_localized: Bool {
		get {
			LF.log("WARNING: getter not implemented")
			return false
		}
		set (b) {
			if b {
				if let text = self.text {
					self.text = LTheme.localization.Str(text)
				}
			}
		}
	}
	@IBInspectable var text_font_name: String? {
		get {
			return font?.fontName
		}
		set (name) {
			font = UIFont(name: name!, size: font!.pointSize)
		}
	}
}

class LFAlertSegue: UIStoryboardSegue {
    override func perform() {
        let source = sourceViewController 
        if let navigation = source.navigationController {
		    let alert = UIAlertController(title: "Message", message: identifier, preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {
				(action: UIAlertAction) -> Void in
			}))
			navigation.presentViewController(alert, animated: true, completion: nil)
        }
    }
}

class LFActionSheetSegue: UIStoryboardSegue {
    override func perform() {
        let source = sourceViewController 
        if let navigation = source.navigationController {
		    let alert = UIAlertController(title: "Message", message: identifier, preferredStyle: .ActionSheet)
			alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {
				(action: UIAlertAction) -> Void in
			}))
			navigation.presentViewController(alert, animated: true, completion: nil)
            //navigation.pushViewController(destinationViewController as UIViewController, animated: false)
        }
    }
}

