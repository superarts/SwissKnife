import UIKit
import MessageUI

public struct SAKit {
	public static let domain = "LFramework"
	public static var version: String {
		get {
			if let ver = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
				if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
					return "\(ver).\(build)"
				}
				return ver
			}
			return ""
		}
	}

	@discardableResult public static func log(_ message: String) -> String {
#if RELEASE
#else
		print(message, terminator: "\n")
#endif
		return message
	}
	@discardableResult public static func log(_ message: String, _ objs: Any?..., separator: String = ", ") -> String {
		var log = ""
		var index = 0
		for obj in objs {
			if obj == nil {
				log += "nil"
			} else if let s = obj as? String {
				log += "\"" + s + "\""
			} else if let s = (obj as AnyObject).description {
				log += s
			} else {
				log += "Any"
			}
			if index < objs.count - 1 {
				log += separator
			}
			index += 1
		}
		log = message + ": " + log
#if RELEASE
#else
		print(log, terminator: "\n")
#endif
		return log
	}

    @discardableResult public static func alert(_ title: String, _ obj: Any?, style: UIAlertControllerStyle = .alert, parent: UIViewController? = nil) -> String {
		var root = parent
		if root == nil, let r = UIApplication.shared.delegate?.window??.rootViewController {
			root = r
		}
        if let root = root {
			var message = ""
			//	TODO: func anyToString
			if obj == nil {
				message = "nil"
			} else if let s = obj as? String {
				message = s
			} else if let s = (obj as AnyObject).description {
				message = s
			} else {
				message = "Any"
			}
            let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
			let action = UIAlertAction(title: "OK", style: .default) { action in
			}
			controller.addAction(action)
            root.present(controller, animated: true, completion: nil)
			return message
        } else {
            SA.log("WARNING: UIAlertController cannot find rootViewController to present", title)
        }
		//let alert = UIAlertView(title: message, message: obj?.description, delegate: nil, cancelButtonTitle: "OK")
		//alert.show()
		return title
	}
	public static func dispatch(_ block: @escaping ()->()) {
		//DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: block)
        DispatchQueue.main.async(execute: block)
	}
	public static func dispatch_delay(_ delay: Double, _ block: @escaping ()->()) {
		let time = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
		DispatchQueue.main.asyncAfter(deadline: time, execute: block)
	}
	public static func dispatch_main(_ block: @escaping ()->()) {
		DispatchQueue.main.async(execute: block)
	}
	public static func smaller<T: Comparable>(_ a: T, _ b: T) -> T {
		if a < b {
			return a
		}
		return b
	}
	public static func greater<T: Comparable>(_ a: T, _ b: T) -> T {
		if a > b {
			return a
		}
		return b
	}

	//	TODO: replace with category property when swift supports it
	public struct keys {
		public static var scroll_page = "sakit-key-scroll-page"
		public static var text_placeholder = "sakit-key-text-placeholder"
		public static var text_color = "sakit-key-text-color"
	}
}

/*
   Private extensions:
		Not following naming convension
   Except for:
   		IBActions
		Notification Observers
 */

public extension NSObject {
	public func associated(_ p: UnsafeRawPointer) -> AnyObject? {
		return objc_getAssociatedObject(self, p) as AnyObject?
	}
	public func associate(_ p: UnsafeRawPointer, object: AnyObject) {
		objc_setAssociatedObject(self, p, object, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
	}
	public func perform(_ key: String, value: AnyObject? = nil) {
		if responds(to: Selector(key)) {
			setValue(value, forKey:key)
		}
	}
}

public extension UIApplication {
	public class func open_string(_ str: String) {
		if let url = URL(string: str) {
			UIApplication.shared.openURL(url)
		}
	}
}

public extension Array {
	/*
	public mutating func append_unique(item: AnyObject) {
		if contains(self, item) {
			self.append(item)
		}
	}
	*/
	public mutating func remove<U: Equatable>(_ object: U) -> Bool {
		for (idx, objectToCompare) in self.enumerated() {
			if let to = objectToCompare as? U {
				if object == to {
					self.remove(at: idx)
					return true
				}
			}
		}
		return false
	}

	/*
	public mutating func replace_or_append<T>(object: T, at index: Int) {
		if self.count > index {
			self[index] = object
		} else {
			self.append(object)
		}
	}
	*/
}

public extension String {
	//	swift 1.2
	/*
	public subscript (i: Int) -> String {
		return String(Array(arrayLiteral: self)[i])
	}
	*/
	public subscript(integerIndex: Int) -> String {
		let index = characters.index(startIndex, offsetBy: integerIndex)
		return String(self[index])
	}
	
/*
	public subscript (r: Range<Int>) -> String {
		var start = advance(startIndex, r.startIndex)
		var end = advance(startIndex, r.endIndex)
		return substringWithRange(Range(start: start, end: end))
	}

	//	s[0..5]
	public subscript (r: Range<Int>) -> String {
		get {
			let startIndex = advance(self.startIndex, r.startIndex)
			let endIndex = advance(startIndex, r.endIndex - r.startIndex)

			return self[Range(start: startIndex, end: endIndex)]
		}
	}
*/
	public subscript (r: CountableClosedRange<Int>) -> String {
		get {
			let startIndex =  self.index(self.startIndex, offsetBy: r.lowerBound)
			let endIndex = self.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
			return self[startIndex...endIndex]
		}
	}
	/*
	public subscript (r: Range<Int>) -> String {
		get {
			let startIndex = self.characters.index(self.startIndex, offsetBy: r.lowerBound)
			let endIndex = self.characters.index(self.startIndex, offsetBy: r.upperBound)
			
			return self[(startIndex ..< endIndex)]
		}
	}
	subscript(integerRange: Range<Int>) -> String {
		let start = startIndex.advancedBy(integerRange.startIndex)
		let end = startIndex.advancedBy(integerRange.endIndex)
		let range = start..<end
		return self[range]
	}
	*/
	public var length: Int {
		get {
			return self.characters.count
		}
	}
	public var word_count: Int {
		get {
			let words = self.components(separatedBy: CharacterSet.whitespacesAndNewlines)
			return words.count
		}
		set(v) {
			SA.log("WARNING no setter for String.word_count")
		}
	}
	public func sub_range(_ head: Int, _ tail: Int) -> String {
		//return self.substringWithRange(Range<String.Index>(start: self.startIndex.advancedBy(head), end: self.endIndex.advancedBy(tail)))
		return self[head...(tail - 1)]
	}
	public func sub_before(_ sub: String) -> String {
        if let range = self.range(of: sub) {
            let index: Int = self.characters.distance(from: self.startIndex, to: range.lowerBound)
			return sub_range(0, index)
		}
		return ""
	}
	public func sub_after(_ sub: String) -> String {
        if let range = self.range(of: sub) {
            let index: Int = self.characters.distance(from: self.startIndex, to: range.lowerBound)
			return sub_range(index + 1, self.length)
		}
		return ""
	}
	public func include(_ find: String, case_sensitive: Bool = true) -> Bool {
		if case_sensitive == false {
			if self.lowercased().range(of: find.lowercased()) == nil {
				return false
			}
		} else if self.range(of: find) == nil {
			return false
		}
		return true
	}
	public func is_email() -> Bool {
		//print("validate calendar: \(self)")
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
		let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
		let predicate = emailTest
		return predicate.evaluate(with: self)
	}
	public func remove_whitespace() -> String {
		return self.replacingOccurrences(of: " ", with:"")
	}
	public func decode_html() -> String {
		var s = self
		s = s.replacingOccurrences(of: "&amp;", with:"&")
		s = s.replacingOccurrences(of: "&quot;", with:"\"")
		s = s.replacingOccurrences(of: "&#039;", with:"'")
		s = s.replacingOccurrences(of: "&#39;", with:"'")
		s = s.replacingOccurrences(of: "&lt;", with:"<")
		s = s.replacingOccurrences(of: "&gt;", with:">")
		return s
	}
	public func escape() -> String {
		if let ret = self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
			return ret
		} else {
			return self
		}
	}
	public func to_filename() -> String {
		if let ret = self.addingPercentEncoding(withAllowedCharacters: .lowercaseLetters) {
			return ret
		} else {
			return self
		}
	}
}
extension String {
    public func boundingSize(width: CGFloat, font: UIFont) -> CGSize {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
		//boundingBox.height += 1
        return boundingBox.size
    }
}

public extension Int {
	public var ordinal: String {
		get {
			var suffix = "th"
			switch self % 10 {
				case 1:
					suffix = "st"
				case 2:
					suffix = "nd"
				case 3:
					suffix = "rd"
				default: ()
			}
			if 10 < (self % 100) && (self % 100) < 20 {
				suffix = "th"
			}
			return String(self) + suffix
		}
	}
}

public extension UserDefaults {
	/*
	public class func object<T: AnyObject>(key: String, _ v: T? = nil) -> T? {
		if let obj: T = v {
			NSUserDefaults.standardUserDefaults().setObject(obj, forKey: key)
			NSUserDefaults.standardUserDefaults().synchronize()
		} else {
			return NSUserDefaults.standardUserDefaults().objectForKey(key) as T?
		}
		return v
	}
	*/
	public class func reset() {
		if let domain = Bundle.main.bundleIdentifier {
			UserDefaults.standard.removePersistentDomain(forName: domain)
		}
	}
	@discardableResult public class func object(_ key: String, _ v: AnyObject? = nil) -> AnyObject? {
		if let obj: AnyObject = v {
			UserDefaults.standard.set(obj, forKey: key)
			UserDefaults.standard.synchronize()
		} else {
			return UserDefaults.standard.object(forKey: key) as AnyObject?
		}
		return v
	}
	@discardableResult public class func bool(_ key: String, _ v: Bool? = nil) -> Bool? {
		if let obj: Bool = v {
			UserDefaults.standard.set(obj, forKey: key)
			UserDefaults.standard.synchronize()
		} else {
			return UserDefaults.standard.bool(forKey: key)
		}
		return v
	}
	@discardableResult public class func integer(_ key: String, _ v: Int? = nil) -> Int? {
		if let obj: Int = v {
			UserDefaults.standard.set(obj, forKey: key)
			UserDefaults.standard.synchronize()
		} else {
			return UserDefaults.standard.integer(forKey: key)
		}
		return v
	}
	@discardableResult public class func string(_ key: String, _ v: String? = nil) -> String? {
		if let obj: String = v {
			UserDefaults.standard.set(obj, forKey: key)
			UserDefaults.standard.synchronize()
		} else {
			return UserDefaults.standard.string(forKey: key)
		}
		return v
	}
	@discardableResult public class func double(_ key: Double, _ v: Double? = nil) -> Double? {
		if let obj: Double = v {
			UserDefaults.standard.set(obj, forKey: key)
			UserDefaults.standard.synchronize()
		} else {
			return UserDefaults.standard.double(forKey: key)
		}
		return v
	}
}

public extension UIView {
	public func remove_all_subviews() {
		for view in subviews {
			view.removeFromSuperview()
		}
	}
	public func enable_border(width border_width: CGFloat = -1, color: UIColor? = nil, radius: CGFloat = -1, is_circle: Bool = false) {
		var f = radius
		if is_circle {
			f = (w < h ? w : h) / 2
		}
		if f >= 0 {
			layer.cornerRadius = f
		}
		if border_width >= 0 {
			layer.borderWidth = border_width
		}
		if color != nil {
			layer.borderColor = color!.cgColor
		}
		layer.masksToBounds = true
	}
	/*
	public func insert_gradient(color1: UIColor = .clearColor(), color2: UIColor = .clearColor(), head: CGPoint = CGPointMake(0, 0), tail: CGPoint = CGPointMake(0, 0)) {
		let colors: Array<AnyObject> = [color1.CGColor, color2.CGColor]
		var gradient = CAGradientLayer()
		gradient.frame = bounds
		gradient.colors = colors
		gradient.startPoint = head
		gradient.endPoint = tail
		layer.insertSublayer(gradient, atIndex:1)
	}
	*/
	//	it supports more than 2 colors, and more color formats (UIColor, rgb, name)
	public func insert_gradient(_ colors:[AnyObject?], point1:CGPoint, point2:CGPoint) {
		var cg_colors: [CGColor] = []
		for obj in colors {
			if let name = obj as? String, let rgb = SAConst.rgb[name] {
				cg_colors.append(UIColor(rgb: rgb).cgColor)
			} else if let rgb = obj as? UInt {
				cg_colors.append(UIColor(rgb: rgb).cgColor)
			} else if let color = obj as? UIColor {
				cg_colors.append(color.cgColor)
			//} else if let color = obj as? CGColor {
			//	cg_colors.append(color)
			} else {
				SA.log("WARNING unknown color class", obj)
			}
		}
		//SA.log("colors", cg_colors)
		let gradient = CAGradientLayer()
		gradient.frame = bounds
		gradient.colors = cg_colors
		gradient.startPoint = point1
		gradient.endPoint = point2
		layer.insertSublayer(gradient, at:0)
	}
	public func add_shadow(_ size:CGSize) {
		let path = UIBezierPath(rect:bounds)
		layer.masksToBounds = false
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOffset = size
		layer.shadowOpacity = 0.2
		layer.shadowPath = path.cgPath
	}
}

public typealias SA = SAKit

public extension UIColor {
	convenience init(rgb:UInt, alpha:CGFloat = 1.0) {
		self.init(
			red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
			green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
			blue: CGFloat(rgb & 0x0000FF) / 255.0,
			alpha: CGFloat(alpha)
		)
	}
	//func rgb() -> (red:Int, green:Int, blue:Int, alpha:Int)?
	func rgb() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            return (red:fRed, green:fGreen, blue:fBlue, alpha:fAlpha)
			/*
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)
            return (red:iRed, green:iGreen, blue:iBlue, alpha:iAlpha)
			*/
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
	static func interpolate(from color1: UIColor, to color2: UIColor, progress fraction: CGFloat) -> UIColor {
		if let v1 = color1.rgb(), let v2 = color2.rgb() {
			let r = (1 - fraction) * v1.red		+ fraction * v2.red
			let g = (1 - fraction) * v1.green	+ fraction * v2.green
			let b = (1 - fraction) * v1.blue	+ fraction * v2.blue
			let a = (1 - fraction) * v1.alpha	+ fraction * v2.alpha
			return UIColor(red: r, green: g, blue: b, alpha: a)
		}
		return color1
	}
}

//  TODO: make a script to create wrapper classes as above
public extension String {
	public func filename_doc(_ namespace: String? = nil) -> String {
		return self.to_filename(namespace, directory:.documentDirectory)
	}
	public func filename_lib(_ namespace: String? = nil) -> String {
		return self.to_filename(namespace, directory:.libraryDirectory)
	}
	public func to_filename(_ namespace: String? = nil, directory: FileManager.SearchPathDirectory) -> String {
		var filename = self
		if namespace != nil {
			filename = namespace! + "-" + (self as String)
		}

		//let paths = NSSearchPathForDirectoriesInDomains(directory, .AllDomainsMask, true)
		if let dir = NSSearchPathForDirectoriesInDomains(directory, .userDomainMask, true).first {
			let url = URL(fileURLWithPath: dir).appendingPathComponent(filename as String)
			return url.path
		}
		SA.log("WARNING: failed to get filename", namespace as AnyObject?)
		return ""
		//return url.absoluteString
	}
	public func file_exists_doc(_ namespace: String? = nil) -> Bool {
		let manager = FileManager.default
		return manager.fileExists(atPath: self.filename_doc(namespace))
	}
	public func file_exists_lib(_ namespace: String? = nil) -> Bool {
		let manager = FileManager.default
		return manager.fileExists(atPath: self.filename_lib(namespace))
	}
}

//  TODO: it is a temporary solution. I'm going to find a good swift friendly library to do this.
public extension UIImageView {
	public func image_load(_ url: String?, clear: Bool = false) {
		if clear == true {
			image = nil
		}
		if url == nil {
			return
		}
		let filename = url!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!	//.lowercaseString
		//filename = filename.stringByReplacingOccurrencesOfString(".", withString:"")
		//filename = filename.stringByReplacingOccurrencesOfString("jpeg", withString:"")
		//filename = filename.stringByReplacingOccurrencesOfString("jpg", withString:"")
		//filename = filename.stringByReplacingOccurrencesOfString("png", withString:"")
		//filename = filename.stringByReplacingOccurrencesOfString("gif", withString:"")
		//filename += ".jpg"

		//if false {
		if filename.file_exists_doc() {
			//SA.log("IMAGE load from file", filename.filename_doc())
			//image = UIImage(named: filename.filename_doc())
			image = UIImage(contentsOfFile: filename.filename_doc())
		} else {
			//dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
			SA.dispatch_delay(0, {
				//SA.log(url!)
				if let data = try? Data(contentsOf: URL(string: url!)!) {
					//SA.log(url!, data.length)
					self.image = UIImage(data: data)
					try? data.write(to: URL(fileURLWithPath: filename.filename_doc()), options: [.atomic])
				}
			})
		}
	}
}

public extension Data {
	public func to_string(_ encoding:String.Encoding = String.Encoding.utf8) -> String? {
		return NSString(data:self as Data, encoding:encoding.rawValue) as String?
	}
}

public extension NSMutableData {
	public func append_string(_ string: String) {
		//let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
		if let data = (string as NSString).data(using: String.Encoding.utf8.rawValue) {
			append(data)
		}
	}
}

public extension UIImage {

	//	TODO: efficiency?
	convenience init?(color: UIColor) {
		self.init(data: UIImagePNGRepresentation(UIImage.imageWithColor(color))!)
	}
	public class func imageWithColor(_ color: UIColor) -> UIImage {
		let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
		UIGraphicsBeginImageContext(rect.size)
		let context = UIGraphicsGetCurrentContext()

		context?.setFillColor(color.cgColor)
		context?.fill(rect)

		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return image!
	}
}

public extension UIScreen {
	public class var w: CGFloat {
		get {
			return UIScreen.main.bounds.width
		}
	}
	public class var h: CGFloat {
		get {
			return UIScreen.main.bounds.height
		}
	}
}

public extension UIFont {
	public class func print_all() {
		let fontFamilyNames = UIFont.familyNames
		for familyName in fontFamilyNames {
			print("------------------------------", terminator: "\n")
			print("Font Family Name = [\(familyName)]", terminator: "\n")
			let names = UIFont.fontNames(forFamilyName: familyName)
			print("Font Names = [\(names)]", terminator: "\n")
		}
	}
}

public extension UIScrollView {
	public var content_x: CGFloat {
		set(f) {
			contentOffset.x = f
		}
		get {
			return contentOffset.x
		}
	}
	public var content_y: CGFloat {
		set(f) {
			contentOffset.y = f
		}
		get {
			return contentOffset.y
		}
	}
	public var animate_x: CGFloat {
		set(f) {
			setContentOffset(CGPoint(x: f, y: contentOffset.y), animated: true)
		}
		get {
			return content_x
		}
	}
	public var animate_y: CGFloat {
		set(f) {
			setContentOffset(CGPoint(x: contentOffset.x, y: f), animated: true)
		}
		get {
			return content_y
		}
	}
	public var content_w: CGFloat {
		set(f) {
			contentSize.width = f
		}
		get {
			return contentSize.width
		}
	}
	public var content_h: CGFloat {
		set(f) {
			contentSize.height = f
		}
		get {
			return contentSize.height
		}
	}

	public var pageControl: UIPageControl? {
		get {
			//return objc_getAssociatedObject(self, &SA.keys.page) as? UIPageControl
			return associated(&SA.keys.scroll_page) as? UIPageControl
		}
		set {
			if let newValue = newValue {
				associate(&SA.keys.scroll_page, object:newValue)
				page_reload()
				//	TODO: casting failed
				//self.delegate = self as? UIScrollViewDelegate
			} else {
				SA.log("WARNING: setting pageControl failed", newValue)
			}
		}
	}
	public func page_reload() {
		if let page = pageControl {
			page.numberOfPages = Int(self.contentSize.width / self.frame.size.width)
			page.currentPage = Int(self.contentOffset.x / self.frame.size.width)
			page.hidesForSinglePage = false
			page.addTarget(self, action:#selector(UIScrollView.page_changed(_:)), for:.valueChanged)
		} else {
			//SA.log("WARNING: pageControl not found")
		}
	}
	public func page_changed(_ page: UIPageControl) {
		UIView.animate(withDuration: 0.3, animations: {
			self.contentOffset = CGPoint(x: self.frame.size.width * CGFloat(page.currentPage), y: 0)
		}) 
	}
	public func scrollViewDidScroll(_ scroll: UIScrollView) {
		page_reload()
	}
}

public extension UIView {
	public var x: CGFloat {
		set(f) {
			frame.origin.x = f
		}
		get {
			return frame.origin.x
		}
	}
	public var y: CGFloat {
		set(f) {
			frame.origin.y = f
		}
		get {
			return frame.origin.y
		}
	}
	public var w: CGFloat {
		set(f) {
			frame.size.width = f
		}
		get {
			return frame.size.width
		}
	}
	public var h: CGFloat {
		set(f) {
			frame.size.height = f
		}
		get {
			return frame.size.height
		}
	}
	public func below(_ view: UIView, offset: CGFloat = 0) {
		y = view.y + view.h + offset
	}
}

//	TODO: dependency
/*
public extension MBProgressHUD {
	public class func show(title: String, view: UIView, duration: Float? = nil) {
		let hud = MBProgressHUD.showHUDAddedTo(view, animated: true) 
		hud.detailsLabelFont = UIFont.systemFontOfSize(18)
		hud.detailsLabelText = title
		if duration != nil {
			hud.mode = MBProgressHUDModeText
			hud.minShowTime = duration!
			hud.graceTime = duration!
			MBProgressHUD.hideAllHUDsForView(view, animated:true)
		}
	}
}
*/

/*
features

build-in IB actions
	sakitActionPop
	sakitActionPopToRoot
	sakitActionDismiss
	sakitActionEndEditing

build-in delegates
	sa_keyboard_height_changed(height: CGFloat)

properties: containers, followed up with
	public override func viewDidLoad() {
		super.viewDidLoad()
		let horizontal_scroll = containers["SegueName-ContainerHorizontalScroll"] as ControllerName_LFHorizontalScrollController
		horizontal_scroll.titles = ["title 1", "title 2"]
	}
*/
//	TODO: why protocol here?
/*
@objc protocol SAViewControllerDelegate {
	optional func sa_keyboard_height_changed(height: CGFloat)
}
public class SAViewController: UIViewController, SAViewControllerDelegate {
*/

public extension UIViewController {
	@IBAction public func sakitActionPop() {
		navigationController?.popViewController(animated: true)
	}
	@IBAction public func sakitActionPopToRoot() {
		navigationController?.popToRootViewController(animated: true)
	}
	@IBAction public func sakitActionDismiss() {
		dismiss(animated: true, completion: nil)
	}
	@IBAction public func sakitActionEndEditing() {
		view.endEditing(true)
	}
	public func pop_to(_ level:Int, animated:Bool = true) {
		if let controllers = navigationController?.viewControllers {
			var index = level
			if index < 0 {
				index = controllers.count - 1 + level
			}
			let controller = controllers[index]
			navigationController?.popToViewController(controller, animated:animated)
		}
	}
  
	public func pushIdentifier(_ controllerIdentifier: String, animated: Bool = true) -> UIViewController? {
		return push_identifier(controllerIdentifier, animated:animated)
	}
	public func push_identifier(_ controllerIdentifier: String, animated: Bool = true, hide_bottom: Bool? = nil) -> UIViewController? {
		if let controller = storyboard?.instantiateViewController(withIdentifier: controllerIdentifier) {
			if let hide = hide_bottom {
				controller.hidesBottomBarWhenPushed = hide
			}
			navigationController?.pushViewController(controller, animated: animated)
			return controller
		}
		return nil
	}
	public func present_identifier(_ controllerIdentifier: String, animated: Bool = true) -> UIViewController? {
		if let controller = storyboard?.instantiateViewController(withIdentifier: controllerIdentifier) {
			self.present(controller, animated:animated, completion:nil)
			return controller
		}
		return nil
	}
}

public extension UISearchBar {
	public func set_text_image(_ text: NSString, icon:UISearchBarIcon, attribute:SADictStrObj? = nil, state:UIControlState = UIControlState()) {
		let textColor: UIColor = UIColor.white
		let textFont: UIFont = UIFont(name: "FontAwesome", size: 15)!
		UIGraphicsBeginImageContext(CGSize(width: 15, height: 15))
		var attr = attribute
		if attr == nil {
			attr = [
				NSFontAttributeName: textFont,
				NSForegroundColorAttributeName: textColor,
			]
		}
		text.draw(in: CGRect(x: 0, y: 0, width: 15, height: 15), withAttributes: attr)
		let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()

		self.setImage(image, for:icon, state:state)
	}
}

public extension UIWebView {
	public func load_string(_ str:String) {
		if let url = URL(string:str) {
			let request = URLRequest(url:url)
			loadRequest(request)
		}
	}
}

public extension UIDevice {
	public class func version_at_least(_ version: String) -> Bool {
		let version_system = UIDevice.current.systemVersion + ".0.0.0"
		return version_system.compare(version, options: NSString.CompareOptions.numeric) == .orderedDescending
	}
}

open class SAViewController: UIViewController {
	var containers: Dictionary<String, UIViewController> = [:]
	
	override open func viewWillAppear(_ animated:Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillShow, object: nil);
		NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillHide, object: nil);
		NotificationCenter.default.addObserver(self, selector: #selector(SAViewController.sa_keyboard_will_show(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
		NotificationCenter.default.addObserver(self, selector: #selector(SAViewController.sa_keyboard_will_hide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
	}
	override open func viewWillDisappear(_ animated:Bool) {
		super.viewWillDisappear(animated)
		//NSNotificationCenter.defaultCenter().removeObserver(self)
		NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillShow, object: nil);
		NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillHide, object: nil);
	}
	override open func prepare(for segue: UIStoryboardSegue, sender: Any!) {
		super.prepare(for: segue, sender:sender)
		//  SA.log("SAViewController controller", segue.destinationViewController)
		/*
		if let controller = segue.destinationViewController as? UIViewController {
			//SA.log("SAViewController segue", segue)
			if let identifier = segue.identifier {
				containers[identifier] = controller
			}
		} else {
			SA.log("SAViewController nil destination", segue.identifier)
		}
		*/
		let controller = segue.destination
		if let identifier = segue.identifier {
			containers[identifier] = controller
		}
	}

	open func sa_keyboard_will_show(_ notification: Notification) {
		if let info: NSDictionary = (notification as NSNotification).userInfo as NSDictionary? {
			let value: NSValue = info.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
			let rect: CGRect = value.cgRectValue
			sa_keyboard_height_changed(rect.height)
		}
	}
	open func sa_keyboard_will_hide(_ notification: Notification) {
		sa_keyboard_height_changed(0)
	}
	open func sa_keyboard_height_changed(_ height: CGFloat) {
	}
	
	/*
	override var shouldAutorotate: Bool {
		return false
	}
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .portrait
	}
	override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
		return .portrait
	}
	*/
}


open class SAHorizontalScrollController: UIViewController, UIScrollViewDelegate {

	var font_active: UIFont?
	var font_inactive: UIFont!
	var labels: Array<UILabel> = []
	var scroll: UIScrollView!
	var page_width: CGFloat = 0.5
	var margin: CGFloat = 20
	var index: Int = 0
	var func_scroll: ((_ index1: Int, _ index2: Int, _ offset: CGFloat) -> Void)?
	//var width_total: CGFloat!

	open var delegate_scroll: UIScrollViewDelegate? {
		didSet {
			//scroll.delegate = delegate_scroll
		}
	}
	
	open var titles: Array<String> = [] {
		didSet {
			reload()
		}
	}
	
	open override func viewDidLoad() {
		super.viewDidLoad()
		view.remove_all_subviews()		//	clean up if it's from storyboard

		//width_total = UIScreen.w
		font_inactive = UIFont.systemFont(ofSize: 16)

		//scroll = UIScrollView(frame: CGRectMake(view.w * (1 - page_width) / 2, 0, view.w * page_width, view.h))
		scroll = UIScrollView(frame: view.bounds)
		//scroll.pagingEnabled = true
		scroll.bounces = false
		scroll.clipsToBounds = false
		scroll.delegate = self
		view.addSubview(scroll)

		let view_overlay = UIView(frame: view.frame)
		view_overlay.addGestureRecognizer(scroll.panGestureRecognizer)
		//view_overlay.backgroundColor = view.backgroundColor
		//view_overlay.insert_gradient(color1: view.backgroundColor!, tail: CGPointMake(0.25, 0))
		//view_overlay.insert_gradient(color2: view.backgroundColor!, head: CGPointMake(0.75, 0), tail: CGPointMake(1, 0))
		view.addSubview(view_overlay)

		//view.backgroundColor = .clearColor()
	}
  
	open func get_width(_ index: Int) -> CGFloat {
		let title = titles[index]
		let frame = title.boundingRect(with: CGSize(width: 0, height: 0),
				options: NSStringDrawingOptions.usesLineFragmentOrigin,
				attributes: [NSFontAttributeName: font_inactive],
				context: nil)
		return margin * 2 + frame.size.width		//	margin is included in label
	}
	open func get_total() -> CGFloat {
		var w_total: CGFloat = 0
		for i in 0 ... titles.count - 1 {
			w_total += get_width(i)
		}
		return w_total
	}
	open func reload() {
		let w_total = get_total()
		let repeat_count = Int(view.w * 2 / w_total + 1)
		//SA.log("width", w_total)
		//SA.log("repeat", repeat_count)

		//	scroll.frame = CGRectMake(view.w * (1 - page_width) / 2, 0, view.w * page_width, view.h)
		for label in labels {
			label.removeFromSuperview()
		}
		labels.removeAll()
		//let w = view.w
		var w_offset: CGFloat = 0
		var w_delta: CGFloat = 0
		for ii in 0 ... repeat_count {
			for i in 0 ... titles.count - 1 {
				let title = titles[i]
				//let fi = CGFloat(i)
				let w = get_width(i)
				//let label = UILabel(frame: CGRectMake(w * 0.25 + w * 0.5 * fi, 0, w * 0.5, view.h))
				//let label = UILabel(frame: CGRectMake(w * page_width * fi, 0, w * page_width, view.h))
				let label = UILabel(frame: CGRect(x: w_offset, y: 0, width: w, height: view.h))
				w_offset += w

				if ii == 0 && i == index {
					w_delta = w_offset - label.w / 2
					//SA.log("default", title)
				}

				label.text = title
				label.textColor = UIColor.white
				//label.backgroundColor = UIColor.grayColor()
				label.textAlignment = NSTextAlignment.center
				label.font = font_inactive!
				scroll.addSubview(label)
				labels.append(label)
			}
		}
		scroll.contentSize = CGSize(width: w_offset, height: view.h)
		scroll.contentOffset = CGPoint(x: w_total + w_delta - view.w / 2, y: 0)
	   
		//view.backgroundColor = UIColor.blueColor()
	}
	open func scrollViewDidScroll(_ scroll: UIScrollView) {
		if scroll.content_x <= 0 {
			scroll.content_x = get_total()
		} else if scroll.content_x >= scroll.content_w - view.w {
			scroll.content_x = get_total()
		}
		var index = get_label_index()
		let label = labels[index]
		var d = label.x + label.w / 2 - view.w / 2 - scroll.content_x
		var index1: Int!
		var index2: Int!
		index %= titles.count
		if d > 0 {
			index1 = index - 1
			index2 = index
		} else {
			index1 = index
			index2 = index + 1
		}
		if index1 < 0 {
			index1 = titles.count - 1
		}
		if index2 >= titles.count {
			index2 = 0
		}
		if func_scroll != nil {
			if d < 0 {
				d /= labels[index2].w
			} else {
				d /= labels[index1].w
				d = d - 1
			}
			func_scroll!(index1, index2, d)
		}
	}
	open func scrollViewDidEndDragging(_ scroll: UIScrollView, willDecelerate decelerate: Bool) {
		scrollViewWillBeginDecelerating(scroll)
	}
	open func scrollViewWillBeginDecelerating(_ scroll: UIScrollView) {
		let label = labels[get_label_index()]
		scroll.animate_x = label.x + label.w / 2 - view.w / 2
	}
	open func get_label_index() -> Int {
		var index = 0
		var d: CGFloat = view.w		//	a bigger value, perhaps FLT_MAX?
		for label in labels {
			let dd = abs(label.x + label.w / 2 - scroll.content_x - view.w / 2)
			if dd < d {
				d = dd
				index = labels.index(of: label)!
			}
		}
		return index
	}
}

open class SALabeledScrollController: UIViewController {
	
}


open class SAMultipleTableController: SAViewController {
	open var sources: [SATableDataSource] = []
	open var tables: [UITableView]! {
		set(array) {
			sources.removeAll()
			_tables.removeAll()
			for table in array {
				let source = SATableDataSource(table: table)
				sources.append(source)
				_tables.append(table)
			}
		}
		get {
			return _tables
		}
	}
	fileprivate var _tables: [UITableView] = []

	/*
	public override func viewDidLoad() {
		super.viewDidLoad()
	}
	*/
	@IBAction open func sakitActionReload() {
		for table in tables {
			table.reloadData()
		}
	}
}

open class SATableController: SAMultipleTableController {
	@IBOutlet open var table: UITableView!
	open var source: SATableDataSource! {
		get {
			return sources[0]
		}
		set(obj) {
			sources = [obj]
		}
	}
	//var source: SATableDataSource!
	
	open override func viewDidLoad() {
		super.viewDidLoad()
		tables = [table]
		//source = SATableDataSource(table: table)
	}
	/*
	public override func awakeFromNib() {
		super.awakeFromNib()
	}
	@IBAction public func sakitActionReload() {
		table.reloadData()
	}
	*/

	//	DELETEME
	/*
	public override func viewWillAppear(animated: Bool) {
		table.estimatedRowHeight = 65.0
		table.rowHeight = UITableViewAutomaticDimension
	}
	*/
}

open class SATableDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {

	private var _table: UITableView!
	open var table: UITableView! {
		get {
			return _table
		}
		set(t) {
			_table = t
			t.dataSource = self
			t.delegate = self
		}
	}
	open var counts: Array<Int> = []
	open var headers: Array<String> = []
	open var header_height: CGFloat = 20

	open var func_cell: ((IndexPath) -> UITableViewCell)! = nil
	open var func_header: ((Int) -> UIView?)? = nil
	open var func_height: ((IndexPath) -> CGFloat)? = nil
	open var func_select: ((IndexPath) -> Void)? = nil
	open var func_deselect: ((IndexPath) -> Void)? = nil
	open var func_select_source: ((IndexPath, SATableDataSource) -> Void)? = nil		//	these 2 will not be called if aboves are not nil
	open var func_deselect_source: ((IndexPath, SATableDataSource) -> Void)? = nil

	override public init() {
		super.init()
	}
	public init(table a_table: UITableView) {
		super.init()
		table = a_table
		/*
		a_table.dataSource = self
		a_table.delegate = self
		table = a_table
		*/
	}

/*
	open func index_alphabet(_ array: Array<String>) -> Array<Array<String>> {
		var ret: Array<Array<String>> = []
		let sorted: Array<String> = array.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
		counts.removeAll()
		headers.removeAll()
		let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		for c in alphabet.characters {
			var a: Array<String> = []
			for s in sorted {
				if String(Array(s.characters)[0]).uppercased() == String(c) {
					a.append(s)
				}
			}
			if a.count > 0 {
				headers.append(String(c))
				counts.append(a.count)
				ret.append(a)
			}
		}
		return ret
	}
*/

	open func numberOfSections(in tableView: UITableView) -> Int {
		return counts.count
	}
	open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return counts[section]
	}
	open func tableView(_ tableView: UITableView, heightForRowAt path: IndexPath) -> CGFloat {
		if func_height != nil {
			return func_height!(path)
		}
		return tableView.rowHeight
	}
	//	header and index
	open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if headers.count > section {
			return headers[section]
		} else {
			return nil
		}
	}
	/*
	open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
	}
	*/

	/*
	public func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
		var array: Array = []
		var index = 0
		for s in headers {
			array.append(s)	//(String(format: "%@", s))
			//if index % 1 == 0 { array.append(".") } 
			//index++
		}
		//array.removeLast()
		return array
	}
	*/
	//	func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int { return index / 2 }
	//	cell and select
	open func tableView(_ tableView: UITableView, cellForRowAt path: IndexPath) -> UITableViewCell {
		if func_cell == nil {
			SA.log("WARNING no func_cell in SATableDataSource", path as AnyObject?)
		}
		return func_cell(path)
	}
	open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if headers.count <= 0 && func_header == nil {
			return 0
		}
		return header_height
	}
	open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if func_header != nil {
			let view = func_header!(section)
			return view
		}
		return nil
	}
	open func tableView(_ tableView: UITableView, didSelectRowAt path: IndexPath) {
		if func_select != nil {
			func_select!(path)
		} else if func_select_source != nil {
			func_select_source!(path, self)
		}
		return
	}
	open func tableView(_ tableView: UITableView, didDeselectRowAt path: IndexPath) {
		if func_deselect != nil {
			func_deselect!(path)
		} else if func_deselect_source != nil {
			func_deselect_source!(path, self)
		}
		return
	}
	open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.layoutIfNeeded()
		cell.backgroundColor = UIColor.clear
	}
}

public struct LFDebug {
	public static var filename = "LDebug.xml"
	public static var is_appending = true

	public static func string(_ namespace: String? = nil) -> String {
		if let s = try? String(contentsOfFile:filename.filename_doc(namespace), encoding: String.Encoding.utf8) {
			return s
		}
		SA.log("LDebug file not found", filename.filename_doc(namespace) as AnyObject?)
		return ""
	}
	public static func log(_ msg: String, _ namespace: String? = nil) {
		var s = string(namespace)
		if let date = Date().to_string() {
			if is_appending {
				s += "\n" + date + ":\t" + msg	
			} else {
				s = date + ":\t" + msg + "\n" + s
			}
		}
		do {
			try s.write(toFile: filename.filename_doc(namespace), atomically:true, encoding:String.Encoding.utf8)
		} catch _ {
			//SA.log("LDebug save error", error)
		}
	}
	public static func clear(_ namespace: String? = nil) {
		do {
			try "".write(toFile: filename.filename_doc(namespace), atomically:true, encoding:String.Encoding.utf8)
		} catch _ {
		}
	}
	public static func log_show(_ namespace: String? = nil) {
		let s = string(namespace)
		SA.log("LDebug", s as AnyObject?)
	}
}

//	cell

open class SACellTitleDetail: UITableViewCell {
	@IBOutlet open var label_title: UILabel!
	@IBOutlet open var label_detail: UILabel!
}

open class SAMailComposer: NSObject, MFMailComposeViewControllerDelegate {
	open func present(parent controller: UIViewController, to recipients: [String]? = nil, subject: String = "", body: String = "", isHtml: Bool = false) {
		if MFMailComposeViewController.canSendMail() {
			let mail = MFMailComposeViewController()
			mail.mailComposeDelegate = self
			if let recipients = recipients {
				mail.setToRecipients(recipients)
			}
			mail.setSubject(subject)
			mail.setMessageBody(body, isHTML: isHtml)
			controller.present(mail, animated: true)
		} else {
			//SA.alert("Email Not Available", "Please check your email account")
			SA.alert("电子邮件不可用", "请检查您的电子邮件设置")
		}
	}

	open func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true)
	}
}