import UIKit

typealias LTDictStrObj = Dictionary<String, AnyObject>
typealias LTDictStrStr = Dictionary<String, String>
typealias LTArrayObj = Array<AnyObject>
typealias LTArrayInt = Array<Int>
typealias LTBlockVoid = (() -> Void)
typealias LTBlockVoidError = ((NSError?) -> Void)
typealias LTBlockVoidObjError = ((AnyObject?, NSError?) -> Void)
typealias LTBlockVoidDict = ((LTDictStrObj?) -> Void)
typealias LTBlockVoidDictError = ((LTDictStrObj?, NSError?) -> Void)
typealias LTBlockVoidArray = ((LTArrayObj?) -> Void)
typealias LTBlockVoidArrayError = ((LTArrayObj?, NSError?) -> Void)

struct LF {
	static let domain = "LFramework"
	static var version: String? {
		get {
			return NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as String?
		}
	}

    static func log(message: String) {
        #if DEBUG
            println(message)
        #endif
    }
    static func log(message: String, _ obj: AnyObject?) {
        #if DEBUG
            if let s = obj as? String {
                println(message + ": '" + s + "'")
            } else if let desc = obj?.description {
                println(message + ": '" + desc + "'")
            } else {
                println(message + ": nil")
            }
        #endif
    }
	static func dispatch_delay(delay: NSTimeInterval, _ block: dispatch_block_t) {
		let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
		dispatch_after(time, dispatch_get_main_queue(), block)
	}
	static func dispatch(block: dispatch_block_t) {
		dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
	}
	static func dispatch_main(block: dispatch_block_t) {
		dispatch_async(dispatch_get_main_queue(), block)
	}
	static func smaller<T: Comparable>(a: T, _ b: T) -> T {
		if a < b {
			return a
		}
		return b
	}
	static func larger<T: Comparable>(a: T, _ b: T) -> T {
		if a > b {
			return a
		}
		return b
	}
}

extension UIView {
    func lf_removeAllSubviews() {
        for view in subviews {
            view.removeFromSuperview()
        }
    }
	func lf_enableBorder(width border_width: CGFloat = -1, color: UIColor? = nil, radius: CGFloat = -1) {
		var f = radius
		if f < 0 {
			f = (w < h ? w : h) / 2
		}
		layer.cornerRadius = f
		if border_width >= 0 {
			layer.borderWidth = border_width
		}
		if color != nil {
			layer.borderColor = color!.CGColor
		}
		layer.masksToBounds = true
	}
	func lf_insertGradient(color1: UIColor = .clearColor(), color2: UIColor = .clearColor(), head: CGPoint = CGPointMake(0, 0), tail: CGPoint = CGPointMake(0, 0)) {
		let colors: Array<AnyObject> = [color1.CGColor, color2.CGColor]
		var gradient = CAGradientLayer()
		gradient.frame = bounds
		gradient.colors = colors
		gradient.startPoint = head
		gradient.endPoint = tail
		layer.insertSublayer(gradient, atIndex:1)
	}
}

/*
extension UIView {
    
    func lf_frame(anotherView: UIView, padding: CGFloat) {
        frame = CGRectMake(
            anotherView.frame.origin.x,
            anotherView.frame.origin.x,
            anotherView.frame.origin.x,
            anotherView.frame.origin.x)
    }
}
*/

//  private extensions: not following naming convension

extension String {
//	TODO: not working?
/*
	subscript (i: Int) -> String {
		return String(Array(self)[i])
	}
	subscript (r: Range<Int>) -> String {
		var start = advance(startIndex, r.startIndex)
		var end = advance(startIndex, r.endIndex)
		return substringWithRange(Range(start: start, end: end))
	}

	//	s[0..5]
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = advance(self.startIndex, r.startIndex)
            let endIndex = advance(startIndex, r.endIndex - r.startIndex)

            return self[Range(start: startIndex, end: endIndex)]
        }
    }
*/

	var length: Int {
		get {
			return countElements(self)
		}
	}
	func sub_range(head: Int, _ tail: Int) -> String {
		return self.substringWithRange(Range<String.Index>(start: advance(self.startIndex, head), end: advance(self.endIndex, tail)))
	}
	func contains(find: String, case_sensitive: Bool = true) -> Bool {
		if case_sensitive == false {
			if self.lowercaseString.rangeOfString(find.lowercaseString) == nil {
				return false
			}
		} else if self.rangeOfString(find) == nil {
			return false
		}
		return true
	}
	func is_email() -> Bool {
        //println("validate calendar: \(self)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        var emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
		if let predicate = emailTest {
			return predicate.evaluateWithObject(self)
		}
        return false
    }
}

extension Int {
    var ordinal: String {
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
            return String(self) + suffix
        }
    }
}

extension NSUserDefaults {
	class func object<T: AnyObject>(key: String, _ v: T? = nil) -> T? {
		if let obj: T = v {
			NSUserDefaults.standardUserDefaults().setObject(obj, forKey: key)
			NSUserDefaults.standardUserDefaults().synchronize()
		} else {
			return NSUserDefaults.standardUserDefaults().objectForKey(key) as T?
		}
		return v
	}
	class func bool(key: String, _ v: Bool? = nil) -> Bool? {
		if let obj: Bool = v {
			NSUserDefaults.standardUserDefaults().setBool(obj, forKey: key)
			NSUserDefaults.standardUserDefaults().synchronize()
		} else {
			return NSUserDefaults.standardUserDefaults().boolForKey(key)
		}
		return v
	}
}

extension UIView {
    func remove_all_subviews() {
        lf_removeAllSubviews()
    }
}

extension UIColor {
	convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

//  TODO: make a script to create wrapper classes as above
extension NSString {
    func filename_doc(_ namespace: String? = nil) -> String {
		var filename = self
		if namespace != nil {
			filename = namespace! + "-" + self
		}
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let dir = paths[0] as String
        return dir.stringByAppendingPathComponent(filename)
    }
    func filename_lib(_ namespace: String? = nil) -> String {
		var filename = self
		if namespace != nil {
			filename = namespace! + "-" + self
		}
        let paths = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)
        let dir = paths[0] as String
        return dir.stringByAppendingPathComponent(filename)
    }
    func file_exists_doc(namespace: String? = nil) -> Bool {
        let manager = NSFileManager.defaultManager()
        return manager.fileExistsAtPath(self.filename_doc(namespace))
    }
    func file_exists_lib(namespace: String? = nil) -> Bool {
        let manager = NSFileManager.defaultManager()
        return manager.fileExistsAtPath(self.filename_lib(namespace))
    }
}

//  TODO: it is a temporary solution. I'm going to find a good swift friendly library to do this.
extension UIImageView {
    func image_load(url: String?, clear: Bool = false) {
		if clear == true {
			image = nil
		}
		if url == nil {
			return
		}
        let filename = url!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!

        //if false {
        if filename.file_exists_doc() {
            image = UIImage(named: filename.filename_doc())
        } else {
            //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            LF.dispatch_delay(0, {
				//LF.log(url!)
                if let data = NSData(contentsOfURL: NSURL(string: url!)!) {
					//LF.log(url!, data.length)
                    self.image = UIImage(data: data)
                    data.writeToFile(filename.filename_doc(), atomically: true)
                }
            })
        }
    }
}

extension UIScreen {
    class var w: CGFloat {
        get {
            return UIScreen.mainScreen().bounds.width
        }
    }
    class var h: CGFloat {
        get {
            return UIScreen.mainScreen().bounds.height
        }
    }
}

extension UIScrollView {
    var content_x: CGFloat {
        set(f) {
            contentOffset.x = f
        }
        get {
            return contentOffset.x
        }
	}
    var content_y: CGFloat {
        set(f) {
            contentOffset.y = f
        }
        get {
            return contentOffset.y
        }
	}
	var animate_x: CGFloat {
        set(f) {
            setContentOffset(CGPointMake(f, contentOffset.y), animated: true)
        }
        get {
            return content_x
        }
	}
	var animate_y: CGFloat {
        set(f) {
            setContentOffset(CGPointMake(contentOffset.x, f), animated: true)
        }
        get {
            return content_y
        }
	}
    var content_w: CGFloat {
        set(f) {
            contentSize.width = f
        }
        get {
            return contentSize.width
        }
	}
    var content_h: CGFloat {
        set(f) {
            contentSize.height = f
        }
        get {
            return contentSize.height
        }
	}
}

extension UIView {
    var x: CGFloat {
        set(f) {
            frame.origin.x = f
        }
        get {
            return frame.origin.x
        }
    }
    var y: CGFloat {
        set(f) {
            frame.origin.y = f
        }
        get {
            return frame.origin.y
        }
    }
    var w: CGFloat {
        set(f) {
            frame.size.width = f
        }
        get {
            return frame.size.width
        }
    }
    var h: CGFloat {
        set(f) {
            frame.size.height = f
        }
        get {
            return frame.size.height
        }
    }
	func below(view: UIView, offset: CGFloat = 0) {
		y = view.y + view.h + offset
	}
}

//	TODO: dependency
extension MBProgressHUD {
	class func show(title: String, view: UIView, duration: Float? = nil) {
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
    override func viewDidLoad() {
        super.viewDidLoad()
        let horizontal_scroll = containers["SegueName-ContainerHorizontalScroll"] as ControllerName_LFHorizontalScrollController
        horizontal_scroll.titles = ["title 1", "title 2"]
    }
*/
//	TODO: why protocol here?
/*
@objc protocol LFViewControllerDelegate {
	optional func lf_keyboardHeightChanged(height: CGFloat)
}
class LFViewController: UIViewController, LFViewControllerDelegate {
*/
class LFViewController: UIViewController {
    var containers: Dictionary<String, UIViewController> = [:]
    
    @IBAction func lf_actionPop() {
        navigationController?.popViewControllerAnimated(true);
    }
    @IBAction func lf_actionPopToRoot() {
        navigationController?.popToRootViewControllerAnimated(true);
    }
    @IBAction func lf_actionDismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func lf_actionEndEditing() {
        view.endEditing(true)
    }
  
	func pushIdentifier(controllerIdentifier: String, animated: Bool = true) -> UIViewController {
		let controller = storyboard?.instantiateViewControllerWithIdentifier(controllerIdentifier) as UIViewController
		navigationController?.pushViewController(controller, animated: animated)
		return controller
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("lf_keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("lf_keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
	}
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        super.prepareForSegue(segue, sender:sender)
        //  LF.log("LFViewController controller", segue.destinationViewController)
        if let controller = segue.destinationViewController as? UIViewController {
            //LF.log("LFViewController segue", segue)
            if let identifier = segue.identifier {
                containers[identifier] = controller
            }
        } else {
            LF.log("LFViewController nil destination", segue.identifier)
        }
    }

	func lf_keyboardWillShow(notification: NSNotification) {
		if let info: NSDictionary = notification.userInfo {
			let value: NSValue = info.valueForKey(UIKeyboardFrameEndUserInfoKey) as NSValue
			let rect: CGRect = value.CGRectValue()
			lf_keyboardHeightChanged(rect.height)
		}
	}
	func lf_keyboardWillHide(notification: NSNotification) {
		lf_keyboardHeightChanged(0)
	}
	func lf_keyboardHeightChanged(height: CGFloat) {
	}
}


class LFHorizontalScrollController: UIViewController, UIScrollViewDelegate {

	var font_active: UIFont?
	var font_inactive: UIFont!
    var labels: Array<UILabel> = []
    var scroll: UIScrollView!
	var page_width: CGFloat = 0.5
	var margin: CGFloat = 20
	var index: Int = 0
	var func_scroll: ((index1: Int, index2: Int, offset: CGFloat) -> Void)?
	//var width_total: CGFloat!

    var delegate_scroll: UIScrollViewDelegate? {
		didSet {
			//scroll.delegate = delegate_scroll
		}
	}
    
    var titles: Array<String> = [] {
        didSet {
            reload()
        }
    }
    
    override func viewDidLoad() {
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
  
	func get_width(index: Int) -> CGFloat {
		let title = titles[index]
		let frame = title.boundingRectWithSize(CGSizeMake(0, 0),
				options: NSStringDrawingOptions.UsesLineFragmentOrigin,
				attributes: [NSFontAttributeName: font_inactive],
				context: nil)
		return margin * 2 + frame.size.width		//	margin is included in label
	}
	func get_total() -> CGFloat {
		var w_total: CGFloat = 0
		for i in 0 ... titles.count - 1 {
			w_total += get_width(i)
		}
		return w_total
	}
    func reload() {
		let w_total = get_total()
		let repeat = Int(view.w * 2 / w_total + 1)
		//LF.log("width", w_total)
		//LF.log("repeat", repeat)

        //	scroll.frame = CGRectMake(view.w * (1 - page_width) / 2, 0, view.w * page_width, view.h)
        for label in labels {
            label.removeFromSuperview()
        }
        labels.removeAll()
        let w = view.w
		var w_offset: CGFloat = 0
		var w_delta: CGFloat = 0
		for ii in 0 ... repeat {
			for i in 0 ... titles.count - 1 {
				let title = titles[i]
				let fi = CGFloat(i)
				let w = get_width(i)
				//let label = UILabel(frame: CGRectMake(w * 0.25 + w * 0.5 * fi, 0, w * 0.5, view.h))
				//let label = UILabel(frame: CGRectMake(w * page_width * fi, 0, w * page_width, view.h))
				let label = UILabel(frame: CGRectMake(w_offset, 0, w, view.h))
				w_offset += w

				if ii == 0 && i == index {
					w_delta = w_offset - label.w / 2
					//LF.log("default", title)
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
	func scrollViewDidScroll(scroll: UIScrollView) {
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
	func scrollViewDidEndDragging(scroll: UIScrollView, willDecelerate decelerate: Bool) {
		scrollViewWillBeginDecelerating(scroll)
	}
	func scrollViewWillBeginDecelerating(scroll: UIScrollView) {
		let label = labels[get_label_index()]
		scroll.animate_x = label.x + label.w / 2 - view.w / 2
	}
	func get_label_index() -> Int {
		var index = 0
		var d: CGFloat = view.w		//	a bigger value, perhaps FLT_MAX?
		for label in labels {
			let dd = abs(label.x + label.w / 2 - scroll.content_x - view.w / 2)
			if dd < d {
				d = dd
				index = find(labels, label)!
			}
		}
		return index
	}
}

class LFLabeledScrollController: UIViewController {
    
}


class LFTableController: LFViewController {
	@IBOutlet var table: UITableView!
	var source: LFTableDataSource!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		source = LFTableDataSource(table: table)
	}
	@IBAction func lf_actionReload() {
        table.reloadData()
	}
}

class LFTableDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {

	var counts: Array<Int> = []
	var headers: Array<String> = []
	var header_height: CGFloat = 20

	var func_cell: ((NSIndexPath) -> UITableViewCell)! = nil
	var func_header: ((Int) -> UIView?)? = nil
	var func_height: ((NSIndexPath) -> CGFloat)? = nil
	var func_select: ((NSIndexPath) -> Void)? = nil
	var func_deselect: ((NSIndexPath) -> Void)? = nil

	init(table: UITableView) {
		super.init()
		table.dataSource = self
		table.delegate = self
	}

	func index_alphabet(array: Array<String>) -> Array<Array<String>> {
		var ret: Array<Array<String>> = []
		let sorted: Array<String> = array.sorted { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
		counts.removeAll()
		headers.removeAll()
		let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		for c in alphabet {
			var a: Array<String> = []
			for s in sorted {
				if String(Array(s)[0]).uppercaseString == String(c) {
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

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return counts.count
	}
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return counts[section]
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath path: NSIndexPath) -> CGFloat {
		if func_height != nil {
			return func_height!(path)
		}
		return tableView.rowHeight
    }
	//	header and index
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
		if headers.count > section {
			return headers[section]
		} else {
			return ""
		}
	}
	/*
	func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
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
	func tableView(tableView: UITableView, cellForRowAtIndexPath path: NSIndexPath) -> UITableViewCell {
		if func_cell == nil {
			LF.log("WARNING no func_cell in LFTableDataSource", path)
		}
        return func_cell(path)
    }
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if headers.count <= 0 && func_header == nil {
			return 0
		}
		return header_height
	}
	func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if func_header != nil {
			let view = func_header!(section)
			return view
		}
		return nil
	}
    func tableView(tableView: UITableView, didSelectRowAtIndexPath path: NSIndexPath) {
		if func_select != nil {
			func_select!(path)
		}
		return
	}
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath path: NSIndexPath) {
		if func_deselect != nil {
			func_deselect!(path)
		}
		return
	}
}

//	TODO: refactor for better naming
struct LDebug {
	static var filename = "LDebug.xml"
	static func log_string(_ namespace: String? = nil) -> String {
		if let s = String(contentsOfFile:filename.filename_doc(namespace), encoding: NSUTF8StringEncoding, error: nil) {
			return s
		}
		LF.log("LDebug file not found", filename.filename_doc(namespace))
		return ""
	}
	static func log(msg: String, _ namespace: String? = nil) {
		var s = log_string(namespace)
		s += "\n" + NSDate().description + "\t" + msg	
		var error: NSError?
		s.writeToFile(filename.filename_doc(namespace), atomically:true, encoding:NSUTF8StringEncoding, error:&error)
		//LF.log("LDebug save error", error)
	}
	static func log_show(_ namespace: String? = nil) {
		var s = log_string(namespace)
		LF.log("LDebug", s)
	}
}
