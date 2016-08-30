import UIKit

public struct SAKit {
	public static let domain = "LFramework"
	public static var version: String {
		get {
			if let ver = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
				if let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
					return "\(ver).\(build)"
				}
				return ver
			}
			return ""
		}
	}

	public static func log(message: String) -> String {
#if RELEASE
#else
		print(message, terminator: "\n")
#endif
		return message
	}
	public static func log(message: String, _ obj: AnyObject?) -> String {
		var log = message + ": nil"
		if let s = obj as? String {
			log = message + ": '" + s + "'"
		} else if let desc = obj?.description {
			log = message + ": '" + desc + "'"
		}
#if RELEASE
#else
		print(log, terminator: "\n")
#endif
		return log
	}
	public static func alert(message: String, _ obj: AnyObject?) -> String {
		//	TODO: use UIAlertController instead
		let alert = UIAlertView(title: message, message: obj?.description, delegate: nil, cancelButtonTitle: "OK")
		alert.show()
		return message
	}
	public static func dispatch(block: dispatch_block_t) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
	}
	public static func dispatch_delay(delay: Double, _ block: dispatch_block_t) {
		let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
		dispatch_after(time, dispatch_get_main_queue(), block)
	}
	public static func dispatch_main(block: dispatch_block_t) {
		dispatch_async(dispatch_get_main_queue(), block)
	}
	public static func smaller<T: Comparable>(a: T, _ b: T) -> T {
		if a < b {
			return a
		}
		return b
	}
	public static func greater<T: Comparable>(a: T, _ b: T) -> T {
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
	public func associated(p: UnsafePointer<Void>) -> AnyObject {
		return objc_getAssociatedObject(self, p)
	}
	public func associate(p: UnsafePointer<Void>, object: AnyObject) {
		objc_setAssociatedObject(self, p, object, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
	}
	public func perform(key: String, value: AnyObject? = nil) {
		if respondsToSelector(Selector(key)) {
			setValue(value, forKey:key)
		}
	}
}

public extension UIApplication {
	public class func open_string(str: String) {
		if let url = NSURL(string: str) {
			UIApplication.sharedApplication().openURL(url)
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
	public mutating func remove<U: Equatable>(object: U) -> Bool {
		for (idx, objectToCompare) in self.enumerate() {
			if let to = objectToCompare as? U {
				if object == to {
					self.removeAtIndex(idx)
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
		let index = startIndex.advancedBy(integerIndex)
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
	public subscript (r: Range<Int>) -> String {
		get {
			let startIndex = self.startIndex.advancedBy(r.startIndex)
			let endIndex = self.startIndex.advancedBy(r.endIndex)
			
			return self[Range(start: startIndex, end: endIndex)]
		}
	}
	/*
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
			let words = self.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
			return words.count
		}
	}
	public func sub_range(head: Int, _ tail: Int) -> String {
		//return self.substringWithRange(Range<String.Index>(start: self.startIndex.advancedBy(head), end: self.endIndex.advancedBy(tail)))
		return self[head...(tail - 1)]
	}
	public func sub_before(sub: String) -> String {
		if let range = self.rangeOfString(sub), let index: Int = self.startIndex.distanceTo(range.startIndex) {
			return sub_range(0, index)
		}
		return ""
	}
	public func include(find: String, case_sensitive: Bool = true) -> Bool {
		if case_sensitive == false {
			if self.lowercaseString.rangeOfString(find.lowercaseString) == nil {
				return false
			}
		} else if self.rangeOfString(find) == nil {
			return false
		}
		return true
	}
	public func is_email() -> Bool {
		//print("validate calendar: \(self)")
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
		let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
		let predicate = emailTest
		return predicate.evaluateWithObject(self)
	}
	public func remove_whitespace() -> String {
		return self.stringByReplacingOccurrencesOfString(" ", withString:"")
	}
	public func decode_html() -> String {
		var s = self
		s = s.stringByReplacingOccurrencesOfString("&amp;", withString:"&")
		s = s.stringByReplacingOccurrencesOfString("&quot;", withString:"\"")
		s = s.stringByReplacingOccurrencesOfString("&#039;", withString:"'")
		s = s.stringByReplacingOccurrencesOfString("&#39;", withString:"'")
		s = s.stringByReplacingOccurrencesOfString("&lt;", withString:"<")
		s = s.stringByReplacingOccurrencesOfString("&gt;", withString:">")
		return s
	}
	public func escape() -> String {
		if let ret = self.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()) {
			return ret
		} else {
			return self
		}
	}
	public func to_filename() -> String {
		if let ret = self.stringByAddingPercentEncodingWithAllowedCharacters(.lowercaseLetterCharacterSet()) {
			return ret
		} else {
			return self
		}
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

public extension NSUserDefaults {
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
		if let domain = NSBundle.mainBundle().bundleIdentifier {
			NSUserDefaults.standardUserDefaults().removePersistentDomainForName(domain)
		}
	}
	public class func object(key: String, _ v: AnyObject? = nil) -> AnyObject? {
		if let obj: AnyObject = v {
			NSUserDefaults.standardUserDefaults().setObject(obj, forKey: key)
			NSUserDefaults.standardUserDefaults().synchronize()
		} else {
			return NSUserDefaults.standardUserDefaults().objectForKey(key)
		}
		return v
	}
	public class func bool(key: String, _ v: Bool? = nil) -> Bool? {
		if let obj: Bool = v {
			NSUserDefaults.standardUserDefaults().setBool(obj, forKey: key)
			NSUserDefaults.standardUserDefaults().synchronize()
		} else {
			return NSUserDefaults.standardUserDefaults().boolForKey(key)
		}
		return v
	}
	public class func integer(key: String, _ v: Int? = nil) -> Int? {
		if let obj: Int = v {
			NSUserDefaults.standardUserDefaults().setInteger(obj, forKey: key)
			NSUserDefaults.standardUserDefaults().synchronize()
		} else {
			return NSUserDefaults.standardUserDefaults().integerForKey(key)
		}
		return v
	}
	public class func string(key: String, _ v: String? = nil) -> String? {
		if let obj: String = v {
			NSUserDefaults.standardUserDefaults().setObject(obj, forKey: key)
			NSUserDefaults.standardUserDefaults().synchronize()
		} else {
			return NSUserDefaults.standardUserDefaults().stringForKey(key)
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
			layer.borderColor = color!.CGColor
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
	public func insert_gradient(colors:[AnyObject?], point1:CGPoint, point2:CGPoint) {
		var cg_colors: [CGColor] = []
		for obj in colors {
			if let name = obj as? String, let rgb = SAConst.rgb[name] {
				cg_colors.append(UIColor(rgb: rgb).CGColor)
			} else if let rgb = obj as? UInt {
				cg_colors.append(UIColor(rgb: rgb).CGColor)
			} else if let color = obj as? UIColor {
				cg_colors.append(color.CGColor)
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
		layer.insertSublayer(gradient, atIndex:0)
	}
	public func add_shadow(size:CGSize) {
		let path = UIBezierPath(rect:bounds)
		layer.masksToBounds = false
		layer.shadowColor = UIColor.blackColor().CGColor
		layer.shadowOffset = size
		layer.shadowOpacity = 0.2
		layer.shadowPath = path.CGPath
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
}

//  TODO: make a script to create wrapper classes as above
public extension NSString {
	public func filename_doc(namespace: String? = nil) -> String {
		return self.to_filename(namespace, directory:.DocumentDirectory)
	}
	public func filename_lib(namespace: String? = nil) -> String {
		return self.to_filename(namespace, directory:.LibraryDirectory)
	}
	public func to_filename(namespace: String? = nil, directory: NSSearchPathDirectory) -> String {
		var filename = self
		if namespace != nil {
			filename = namespace! + "-" + (self as String)
		}

		//let paths = NSSearchPathForDirectoriesInDomains(directory, .AllDomainsMask, true)
		if let dir = NSSearchPathForDirectoriesInDomains(directory, .UserDomainMask, true).first {
			let url = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(filename as String)
			if let path = url.path {
				return path
			}
		}
		SA.log("WARNING: failed to get filename", namespace)
		return ""
		//return url.absoluteString
	}
	public func file_exists_doc(namespace: String? = nil) -> Bool {
		let manager = NSFileManager.defaultManager()
		return manager.fileExistsAtPath(self.filename_doc(namespace))
	}
	public func file_exists_lib(namespace: String? = nil) -> Bool {
		let manager = NSFileManager.defaultManager()
		return manager.fileExistsAtPath(self.filename_lib(namespace))
	}
}

//  TODO: it is a temporary solution. I'm going to find a good swift friendly library to do this.
public extension UIImageView {
	public func image_load(url: String?, clear: Bool = false) {
		if clear == true {
			image = nil
		}
		if url == nil {
			return
		}
		let filename = url!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!	//.lowercaseString
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
				if let data = NSData(contentsOfURL: NSURL(string: url!)!) {
					//SA.log(url!, data.length)
					self.image = UIImage(data: data)
					data.writeToFile(filename.filename_doc(), atomically: true)
				}
			})
		}
	}
}

public extension NSData {
	public func to_string(encoding:UInt = NSUTF8StringEncoding) -> String? {
		return NSString(data:self, encoding:encoding) as? String
	}
}

public extension NSMutableData {
	public func append_string(string: String) {
		//let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
		if let data = (string as NSString).dataUsingEncoding(NSUTF8StringEncoding) {
			appendData(data)
		}
	}
}

public extension UIImage {

	//	TODO: efficiency?
	convenience init?(color: UIColor) {
		self.init(data: UIImagePNGRepresentation(UIImage.imageWithColor(color))!)
	}
	public class func imageWithColor(color: UIColor) -> UIImage {
		let rect = CGRectMake(0, 0, 1, 1)
		UIGraphicsBeginImageContext(rect.size)
		let context = UIGraphicsGetCurrentContext()

		CGContextSetFillColorWithColor(context, color.CGColor)
		CGContextFillRect(context, rect)

		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return image
	}
}

public extension UIScreen {
	public class var w: CGFloat {
		get {
			return UIScreen.mainScreen().bounds.width
		}
	}
	public class var h: CGFloat {
		get {
			return UIScreen.mainScreen().bounds.height
		}
	}
}

public extension UIFont {
	public class func print_all() {
		let fontFamilyNames = UIFont.familyNames()
		for familyName in fontFamilyNames {
			print("------------------------------", terminator: "\n")
			print("Font Family Name = [\(familyName)]", terminator: "\n")
			let names = UIFont.fontNamesForFamilyName(familyName)
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
			setContentOffset(CGPointMake(f, contentOffset.y), animated: true)
		}
		get {
			return content_x
		}
	}
	public var animate_y: CGFloat {
		set(f) {
			setContentOffset(CGPointMake(contentOffset.x, f), animated: true)
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
			page.addTarget(self, action:#selector(UIScrollView.page_changed(_:)), forControlEvents:.ValueChanged)
		} else {
			SA.log("WARNING: pageControl not found")
		}
	}
	public func page_changed(page: UIPageControl) {
		UIView.animateWithDuration(0.3) {
			self.contentOffset = CGPointMake(self.frame.size.width * CGFloat(page.currentPage), 0)
		}
	}
	public func scrollViewDidScroll(scroll: UIScrollView) {
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
	public func below(view: UIView, offset: CGFloat = 0) {
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
	lf_actionPop
	lf_actionPopToRoot
	lf_actionDismiss
	lf_actionEndEditing

build-in delegates
	lf_keyboardHeightChanged(height: CGFloat)

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
	optional func lf_keyboardHeightChanged(height: CGFloat)
}
public class SAViewController: UIViewController, SAViewControllerDelegate {
*/

public extension UIViewController {
	@IBAction public func sakitActionPop() {
		navigationController?.popViewControllerAnimated(true)
	}
	@IBAction public func sakitActionPopToRoot() {
		navigationController?.popToRootViewControllerAnimated(true)
	}
	@IBAction public func sakitActionDismiss() {
		dismissViewControllerAnimated(true, completion: nil)
	}
	@IBAction public func sakitActionEndEditing() {
		view.endEditing(true)
	}
	public func pop_to(level:Int, animated:Bool = true) {
		if let controllers = navigationController?.viewControllers {
			var index = level
			if index < 0 {
				index = controllers.count - 1 + level
			}
			let controller = controllers[index]
			navigationController?.popToViewController(controller, animated:animated)
		}
	}
  
	public func pushIdentifier(controllerIdentifier: String, animated: Bool = true) -> UIViewController? {
		return push_identifier(controllerIdentifier, animated:animated)
	}
	public func push_identifier(controllerIdentifier: String, animated: Bool = true, hide_bottom: Bool? = nil) -> UIViewController? {
		if let controller = storyboard?.instantiateViewControllerWithIdentifier(controllerIdentifier) {
			if let hide = hide_bottom {
				controller.hidesBottomBarWhenPushed = hide
			}
			navigationController?.pushViewController(controller, animated: animated)
			return controller
		}
		return nil
	}
	public func present_identifier(controllerIdentifier: String, animated: Bool = true) -> UIViewController? {
		if let controller = storyboard?.instantiateViewControllerWithIdentifier(controllerIdentifier) {
			self.presentViewController(controller, animated:animated, completion:nil)
			return controller
		}
		return nil
	}
}

public extension UISearchBar {
	public func set_text_image(text: NSString, icon:UISearchBarIcon, attribute:SADictStrObj? = nil, state:UIControlState = .Normal) {
		let textColor: UIColor = UIColor.whiteColor()
		let textFont: UIFont = UIFont(name: "FontAwesome", size: 15)!
		UIGraphicsBeginImageContext(CGSizeMake(15, 15))
		var attr = attribute
		if attr == nil {
			attr = [
				NSFontAttributeName: textFont,
				NSForegroundColorAttributeName: textColor,
			]
		}
		text.drawInRect(CGRectMake(0, 0, 15, 15), withAttributes: attr)
		let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		self.setImage(image, forSearchBarIcon:icon, state:state)
	}
}

public extension UIWebView {
	public func load_string(str:String) {
		if let url = NSURL(string:str) {
			let request = NSURLRequest(URL:url)
			loadRequest(request)
		}
	}
}

public extension UIDevice {
	public class func version_at_least(version: String) -> Bool {
		let version_system = UIDevice.currentDevice().systemVersion + ".0.0.0"
		return version_system.compare(version, options: NSStringCompareOptions.NumericSearch) == .OrderedDescending
	}
}

public class SAViewController: UIViewController {
	var containers: Dictionary<String, UIViewController> = [:]
	
	override public func viewWillAppear(animated:Bool) {
		super.viewWillAppear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillShowNotification, object: nil);
		NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillHideNotification, object: nil);
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SAViewController.lf_keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SAViewController.lf_keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
	}
	override public func viewWillDisappear(animated:Bool) {
		super.viewWillDisappear(animated)
		//NSNotificationCenter.defaultCenter().removeObserver(self)
		NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillShowNotification, object: nil);
		NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillHideNotification, object: nil);
	}
	override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
		super.prepareForSegue(segue, sender:sender)
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
		let controller = segue.destinationViewController
		if let identifier = segue.identifier {
			containers[identifier] = controller
		}
	}

	public func lf_keyboardWillShow(notification: NSNotification) {
		if let info: NSDictionary = notification.userInfo {
			let value: NSValue = info.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
			let rect: CGRect = value.CGRectValue()
			lf_keyboardHeightChanged(rect.height)
		}
	}
	public func lf_keyboardWillHide(notification: NSNotification) {
		lf_keyboardHeightChanged(0)
	}
	public func lf_keyboardHeightChanged(height: CGFloat) {
	}
}


public class SAHorizontalScrollController: UIViewController, UIScrollViewDelegate {

	var font_active: UIFont?
	var font_inactive: UIFont!
	var labels: Array<UILabel> = []
	var scroll: UIScrollView!
	var page_width: CGFloat = 0.5
	var margin: CGFloat = 20
	var index: Int = 0
	var func_scroll: ((index1: Int, index2: Int, offset: CGFloat) -> Void)?
	//var width_total: CGFloat!

	public var delegate_scroll: UIScrollViewDelegate? {
		didSet {
			//scroll.delegate = delegate_scroll
		}
	}
	
	public var titles: Array<String> = [] {
		didSet {
			reload()
		}
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		view.remove_all_subviews()		//	clean up if it's from storyboard

		//width_total = UIScreen.w
		font_inactive = UIFont.systemFontOfSize(16)

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
		//view_overlay.lf_insertGradient(color1: view.backgroundColor!, tail: CGPointMake(0.25, 0))
		//view_overlay.lf_insertGradient(color2: view.backgroundColor!, head: CGPointMake(0.75, 0), tail: CGPointMake(1, 0))
		view.addSubview(view_overlay)

		//view.backgroundColor = .clearColor()
	}
  
	public func get_width(index: Int) -> CGFloat {
		let title = titles[index]
		let frame = title.boundingRectWithSize(CGSizeMake(0, 0),
				options: NSStringDrawingOptions.UsesLineFragmentOrigin,
				attributes: [NSFontAttributeName: font_inactive],
				context: nil)
		return margin * 2 + frame.size.width		//	margin is included in label
	}
	public func get_total() -> CGFloat {
		var w_total: CGFloat = 0
		for i in 0 ... titles.count - 1 {
			w_total += get_width(i)
		}
		return w_total
	}
	public func reload() {
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
				let label = UILabel(frame: CGRectMake(w_offset, 0, w, view.h))
				w_offset += w

				if ii == 0 && i == index {
					w_delta = w_offset - label.w / 2
					//SA.log("default", title)
				}

				label.text = title
				label.textColor = UIColor.whiteColor()
				//label.backgroundColor = UIColor.grayColor()
				label.textAlignment = NSTextAlignment.Center
				label.font = font_inactive!
				scroll.addSubview(label)
				labels.append(label)
			}
		}
		scroll.contentSize = CGSizeMake(w_offset, view.h)
		scroll.contentOffset = CGPointMake(w_total + w_delta - view.w / 2, 0)
	   
		//view.backgroundColor = UIColor.blueColor()
	}
	public func scrollViewDidScroll(scroll: UIScrollView) {
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
			func_scroll!(index1: index1, index2: index2, offset: d)
		}
	}
	public func scrollViewDidEndDragging(scroll: UIScrollView, willDecelerate decelerate: Bool) {
		scrollViewWillBeginDecelerating(scroll)
	}
	public func scrollViewWillBeginDecelerating(scroll: UIScrollView) {
		let label = labels[get_label_index()]
		scroll.animate_x = label.x + label.w / 2 - view.w / 2
	}
	public func get_label_index() -> Int {
		var index = 0
		var d: CGFloat = view.w		//	a bigger value, perhaps FLT_MAX?
		for label in labels {
			let dd = abs(label.x + label.w / 2 - scroll.content_x - view.w / 2)
			if dd < d {
				d = dd
				index = labels.indexOf(label)!
			}
		}
		return index
	}
}

public class SALabeledScrollController: UIViewController {
	
}


public class SAMultipleTableController: SAViewController {
	public var sources: [SATableDataSource] = []
	public var tables: [UITableView]! {
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
	private var _tables: [UITableView] = []

	/*
	public override func viewDidLoad() {
		super.viewDidLoad()
	}
	*/
	@IBAction public func sakitActionReload() {
		for table in tables {
			table.reloadData()
		}
	}
}

public class SATableController: SAMultipleTableController {
	@IBOutlet public var table: UITableView!
	public var source: SATableDataSource! {
		get {
			return sources[0]
		}
		set(obj) {
			sources = [obj]
		}
	}
	//var source: SATableDataSource!
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		tables = [table]
		//source = SATableDataSource(table: table)
	}
	/*
	public override func awakeFromNib() {
		super.awakeFromNib()
	}
	@IBAction public func lf_actionReload() {
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

public class SATableDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {

	public var table: UITableView!
	public var counts: Array<Int> = []
	public var headers: Array<String> = []
	public var header_height: CGFloat = 20

	public var func_cell: ((NSIndexPath) -> UITableViewCell)! = nil
	public var func_header: ((Int) -> UIView?)? = nil
	public var func_height: ((NSIndexPath) -> CGFloat)? = nil
	public var func_select: ((NSIndexPath) -> Void)? = nil
	public var func_deselect: ((NSIndexPath) -> Void)? = nil
	public var func_select_source: ((NSIndexPath, SATableDataSource) -> Void)? = nil		//	these 2 will not be called if aboves are not nil
	public var func_deselect_source: ((NSIndexPath, SATableDataSource) -> Void)? = nil

	public init(table a_table: UITableView) {
		super.init()
		a_table.dataSource = self
		a_table.delegate = self
		table = a_table
	}

	public func index_alphabet(array: Array<String>) -> Array<Array<String>> {
		var ret: Array<Array<String>> = []
		let sorted: Array<String> = array.sort { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
		counts.removeAll()
		headers.removeAll()
		let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		for c in alphabet.characters {
			var a: Array<String> = []
			for s in sorted {
				if String(Array(s.characters)[0]).uppercaseString == String(c) {
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

	public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return counts.count
	}
	public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return counts[section]
	}
	public func tableView(tableView: UITableView, heightForRowAtIndexPath path: NSIndexPath) -> CGFloat {
		if func_height != nil {
			return func_height!(path)
		}
		return tableView.rowHeight
	}
	//	header and index
	public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if headers.count > section {
			return headers[section]
		} else {
			return nil
		}
	}
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
	public func tableView(tableView: UITableView, cellForRowAtIndexPath path: NSIndexPath) -> UITableViewCell {
		if func_cell == nil {
			SA.log("WARNING no func_cell in SATableDataSource", path)
		}
		return func_cell(path)
	}
	public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if headers.count <= 0 && func_header == nil {
			return 0
		}
		return header_height
	}
	public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if func_header != nil {
			let view = func_header!(section)
			return view
		}
		return nil
	}
	public func tableView(tableView: UITableView, didSelectRowAtIndexPath path: NSIndexPath) {
		if func_select != nil {
			func_select!(path)
		} else if func_select_source != nil {
			func_select_source!(path, self)
		}
		return
	}
	public func tableView(tableView: UITableView, didDeselectRowAtIndexPath path: NSIndexPath) {
		if func_deselect != nil {
			func_deselect!(path)
		} else if func_deselect_source != nil {
			func_deselect_source!(path, self)
		}
		return
	}
	public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		cell.layoutIfNeeded()
		cell.backgroundColor = UIColor.clearColor()
	}
}

public struct LFDebug {
	public static var filename = "LDebug.xml"
	public static var is_appending = true

	public static func string(namespace: String? = nil) -> String {
		if let s = try? String(contentsOfFile:filename.filename_doc(namespace), encoding: NSUTF8StringEncoding) {
			return s
		}
		SA.log("LDebug file not found", filename.filename_doc(namespace))
		return ""
	}
	public static func log(msg: String, _ namespace: String? = nil) {
		var s = string(namespace)
		if let date = NSDate().to_string() {
			if is_appending {
				s += "\n" + date + ":\t" + msg	
			} else {
				s = date + ":\t" + msg + "\n" + s
			}
		}
		do {
			try s.writeToFile(filename.filename_doc(namespace), atomically:true, encoding:NSUTF8StringEncoding)
		} catch _ {
			//SA.log("LDebug save error", error)
		}
	}
	public static func clear(namespace: String? = nil) {
		do {
			try "".writeToFile(filename.filename_doc(namespace), atomically:true, encoding:NSUTF8StringEncoding)
		} catch _ {
		}
	}
	public static func log_show(namespace: String? = nil) {
		let s = string(namespace)
		SA.log("LDebug", s)
	}
}

//	cell

public class SACellTitleDetail: UITableViewCell {
	@IBOutlet public var label_title: UILabel!
	@IBOutlet public var label_detail: UILabel!
}