import UIKit

//	current you'll have to have UIApplicationMain(C_ARGC, C_ARGV, nil, NSStringFromClass(AppDelegate)) to successfully init the localized strings in storyboard
public struct SATheme {
	public struct localization {
		public enum Language: String {
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
		public static var language = Language(rawValue: Locale.preferredLanguages[0] )
		public static func language_reload() {
			language = Language(rawValue: Locale.preferredLanguages[0] )
		}
		public static var language_default: Language? = Language.English
		public static var languages = [
			Language.English,
			Language.ChineseSimplified,
			Language.SpanishMexico,
		]
		public static var languages_alias = [
			Language.EnglishAustralia.rawValue:			Language.English,
			Language.EnglishUnitedStates.rawValue:		Language.English,
			Language.EnglishUnitedKingdom.rawValue:		Language.English,
			Language.ChineseTraditional.rawValue:		Language.ChineseSimplified,
			Language.Spanish.rawValue:					Language.SpanishMexico,
		]
		public static var languages_default = "en"
		public static var strings: [String:[String]] = [
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
		public class StringPack {
			var dictionary: [String:[String]] = [:]
			var auto_first_language: Bool = false
			init(auto: Bool = false) {
				//super.init()
				auto_first_language = auto
			}
			public func append(key:String, _ value:String) {
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
		public static func strings_append(_ dict: SADictStrObj) {//[String:[String]]) {
			for (key, value) in dict {
				if let dict = value as? [String] {
					strings[key] = dict
				}
			}
		}
		public static func language_current(_ index: Int? = nil) -> Int? {
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
				i = languages.index(of: lang)

				//	if language is not supported directly, check alias
				if i == nil {
					if let lang = languages_alias[lang.rawValue] {
						i = languages.index(of: lang)
					}
				}
			}
			if i == nil && language_default != nil {
				i = 0
			}
			return i
		}
		public static func STR(_ key:String, index: Int? = nil) -> String {
			return str(key, index:index).uppercased()
		}
		public static func Str(_ key:String, index: Int? = nil) -> String {
			let s = str(key, index:index)
			return s
			//return s[0].uppercased() + s[1...s.length]
		}
		public static func str(_ key:String, index: Int? = nil) -> String {
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
				if let array = strings[key] , i < array.count {
					return array[i]
				}
			}
			return key
		}
	}
}

//	UIKit + Interface Builder: define various UIView properties in IB

public extension UITabBarController {
	@IBInspectable var selectedTabIndex: Int {
		get {
			return selectedIndex
		}
		set(index) {
			selectedIndex = index
		}
	}
}

public extension UIView {
	//	TODO: add getters when extension property is added - having problem with associating in swift (key cannot be a string variable)
	//	WARNING: fontName of UIView will be deprecated soon, use textFontName etc. instead.
	@IBInspectable var fontName: String? {
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
				if let attr = segment.titleTextAttributes(for: UIControlState()), let font = attr[NSFontAttributeName] as? UIFont {
					font_size = font.pointSize
				}
				let attr = [NSFontAttributeName: UIFont(name: name!, size: font_size)!]
				segment.setTitleTextAttributes(attr, for: UIControlState())
			} else {
				SA.log("WARNING unknown type for fontName in Interface Builder", self)
			}
		}
	}
	@IBInspectable var enableMaskCircle: Bool {
		get {
			SA.log("WARNING no getter for UIView.enableMaskCircle")
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
	@IBInspectable var maskRadius: CGFloat {
		get {
			SA.log("WARNING no getter for UIView.maskRadius")
			return 0
		}
		set (f) {
			enable_border(radius: f)
		}
	}
	@IBInspectable var borderWidth: CGFloat {
		get {
			SA.log("WARNING no getter for UIView.borderWidth")
			return 0
		}
		set (f) {
			enable_border(width: f)
		}
	}
	@IBInspectable var borderColor: UIColor? {
		get {
			SA.log("WARNING no getter for UIView.borderColor")
			return nil
		}
		set (c) {
			enable_border(color: c)
		}
	}
	@IBInspectable var gradientTop: UIColor? {
		get {
			SA.log("WARNING no getter for UIView.gradientTop")
			return nil
		}
		set (c) {
			insert_gradient([c, backgroundColor], 
					point1:CGPoint(x: 0, y: 0),
					point2:CGPoint(x: 0, y: 1))
		}
	}
	@IBInspectable var shadowDown: CGFloat {
		get {
			SA.log("WARNING no getter for UIView.shadowDown")
			return 0
		}
		set (f) {
            SA.dispatch_delay(0.1, {
                self.add_shadow(CGSize(width: 0, height: f))
            })
		}
	}
}

public extension UILabel {
	@IBInspectable var textLocalized: String? {
		get {
			return self.text
		}
		set (s) {
			self.text = SATheme.localization.Str(s!)
		}
	}
	@IBInspectable var textAutoLocalized: Bool {
		get {
			SA.log("WARNING: getter not implemented")
			return false
		}
		set (b) {
			if b {
				if let text = self.text {
					self.text = SATheme.localization.Str(text)
				}
			}
		}
	}
	@IBInspectable var textFontName: String? {
		get {
			return font.fontName
		}
		set (name) {
			font = UIFont(name: name!, size: font.pointSize)
		}
	}
}

public extension UITextField {
	@IBInspectable var paddingLeft: CGFloat {
		get {
			SA.log("WARNING no getter for UITextField.paddingLeft")
			return 0
		}
		set (f) {
			layer.sublayerTransform = CATransform3DMakeTranslation(f, 0, 0)
		}
	}
	@IBInspectable var textLocalized: String? {
		get {
			return self.text
		}
		set (s) {
			self.text = SATheme.localization.Str(s!)
		}
	}
	@IBInspectable var textAutoLocalized: Bool {
		get {
			SA.log("WARNING: getter not implemented")
			return false
		}
		set (b) {
			if b {
				if let text = self.text {
					self.text = SATheme.localization.Str(text)
				}
			}
		}
	}
	@IBInspectable var textFontName: String? {
		get {
			return font?.fontName
		}
		set (name) {
			font = UIFont(name: name!, size: font!.pointSize)
		}
	}
}

public extension UIScrollView {
	@IBInspectable var contentWidth: CGFloat {
		get {
			return content_w
		}
		set (f) {
			content_w = f
		}
	}
	@IBInspectable var contentHeight: CGFloat {
		get {
			return content_h
		}
		set (f) {
			content_h = f
		}
	}
}

public extension UIBarItem {
	@IBInspectable var titleLocalized: String? {
		get {
			return self.title
		}
		set (s) {
			self.title = SATheme.localization.Str(s!)
		}
	}
	@IBInspectable var autoLocalized: Bool {
		get {
			return false
		}
		set (b) {
			if b {
				if let title = self.title {
					self.title = SATheme.localization.Str(title)
				}
			}
		}
	}
}

public extension UIButton {
	@IBInspectable var titleAlignCenter: Bool {
		get {
			if let label = titleLabel {
				return label.textAlignment == .center
			}
			return false
		}
		set (f) {
			if let label = titleLabel {
				label.textAlignment = .center
			}
		}
	}
	@IBInspectable var highlightedBackgroundColor: UIColor {
		get {
			return UIColor.black		//	TODO
		}
		set (color) {
			//let image = UIImage(CIImage: CIImage(color: CIColor(color: color)))	//why not working?
			let image = UIImage(color: color)
			setBackgroundImage(image, for: .highlighted)
		}
	}
	@IBInspectable var selectedBackgroundColor: UIColor {
		get {
			return UIColor.black		//	TODO
		}
		set (color) {
			let image = UIImage(color: color)
			setBackgroundImage(image, for: .selected)
		}
	}
	@IBInspectable var disabledBackgroundColor: UIColor {
		get {
			return UIColor.black		//	TODO
		}
		set (color) {
			let image = UIImage(color: color)
			setBackgroundImage(image, for: .disabled)
		}
	}
	//	TODO: @IBInspectable var selected_title_localized: String? { }
	@IBInspectable var normalTitleLocalized: String? {
		get {
			return title(for: UIControlState())
		}
		set (s) {
			setTitle(SATheme.localization.Str(s!), for:UIControlState())
		}
	}
	@IBInspectable var normalTextAutoLocalized: Bool {
		get {
			SA.log("WARNING: getter not implemented")
			return false
		}
		set (b) {
			if b {
				if let title = title(for: UIControlState()) {
					setTitle(SATheme.localization.Str(title), for:UIControlState())
				}
			}
		}
	}
	@IBInspectable var highlightedTitleLocalized: String? {
		get {
			return title(for: .highlighted)
		}
		set (s) {
			setTitle(SATheme.localization.Str(s!), for:.highlighted)
		}
	}
	@IBInspectable var highlightedTextAutoLocalized: Bool {
		get {
			SA.log("WARNING: getter not implemented")
			return false
		}
		set (b) {
			if b {
				if let title = title(for: .highlighted) {
					setTitle(SATheme.localization.Str(title), for:.highlighted)
				}
			}
		}
	}
	@IBInspectable var labelFontName: String? {
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

public extension UITextView {
	@IBInspectable var alignMiddleVertical: Bool {
		get {
			return false	//	TODO
		}
		set (b) {
			if b {
				self.addObserver(self, forKeyPath:"frame", options:.new, context:nil)
				self.addObserver(self, forKeyPath:"contentSize", options:.new, context:nil)
			}
		}
	}
	@IBInspectable var placeholder: String {
		get {
            return associated(&SA.keys.text_placeholder) as! String     //  TODO: make sure it's nil.. for now
		}
		set (s) {
			associate(&SA.keys.text_placeholder, object:s as AnyObject)
			//associate(&SA.keys.text_color, object:textColor!)
			self.text = s
			//NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("sa_text_changed:"), name:UITextViewTextDidChangeNotification, object: nil);
			NotificationCenter.default.addObserver(self, selector: #selector(UITextView.sa_text_edit_began(_:)), name:NSNotification.Name.UITextViewTextDidBeginEditing, object: nil);
			NotificationCenter.default.addObserver(self, selector: #selector(UITextView.sa_text_edit_ended(_:)), name:NSNotification.Name.UITextViewTextDidEndEditing, object: nil);
		}
	}

	//	observers should be removed manually. TODO: find a better solution
	public func remove_observer_alignment() {
		//NSNotificationCenter.defaultCenter().removeObserver(self)
		self.removeObserver(self, forKeyPath:"frame")
		self.removeObserver(self, forKeyPath:"contentSize")
	}
	public func remove_observer_placeholder() {
		//NSNotificationCenter.defaultCenter().removeObserver(self, name:UITextViewTextDidChangeNotification, object: nil);
		NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UITextViewTextDidBeginEditing, object: nil);
		NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UITextViewTextDidEndEditing, object: nil);
	}

	override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey:Any]?, context: UnsafeMutableRawPointer?) {
		if let _ = object as? UITextView {
			sa_reload_align_middle_vertical()
		}
	}
	public func sa_reload_align_middle_vertical() {
		var y: CGFloat = (self.bounds.size.height - self.contentSize.height * self.zoomScale)/2.0;
		if y < 0 {
			y = 0
		}
		self.content_y = -y
	}
	//func sa_text_changed(notification: NSNotification) { }
	public func sa_text_edit_began(_ notification: Notification) {
		if self.text == self.placeholder {
			self.text = ""
            //self.textColor = associated(&SA.keys.text_color) as? UIColor
		}
	}
	public func sa_text_edit_ended(_ notification: Notification) {
		if self.text == "" {
			self.text = self.placeholder
            //self.textColor = .grayColor()
		}
	}
	@IBInspectable var textLocalized: String? {
		get {
			return self.text
		}
		set (s) {
			self.text = SATheme.localization.Str(s!)
		}
	}
	@IBInspectable var textAutoLocalized: Bool {
		get {
			SA.log("WARNING: getter not implemented")
			return false
		}
		set (b) {
			if b {
				if let text = self.text {
					self.text = SATheme.localization.Str(text)
				}
			}
		}
	}
	@IBInspectable var textFontName: String? {
		get {
			return font?.fontName
		}
		set (name) {
			font = UIFont(name: name!, size: font!.pointSize)
		}
	}
}

open class SAAlertSegue: UIStoryboardSegue {
    open override func perform() {
        //let source = source
        if let navigation = source.navigationController {
		    let alert = UIAlertController(title: "Message", message: identifier, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
				(action: UIAlertAction) -> Void in
			}))
			navigation.present(alert, animated: true, completion: nil)
        }
    }
}

open class SAActionSheetSegue: UIStoryboardSegue {
    open override func perform() {
        //let source = source
        if let navigation = source.navigationController {
		    let alert = UIAlertController(title: "Message", message: identifier, preferredStyle: .actionSheet)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
				(action: UIAlertAction) -> Void in
			}))
			navigation.present(alert, animated: true, completion: nil)
            //navigation.pushViewController(destinationViewController as UIViewController, animated: false)
        }
    }
}
