// Pod/Classes/SAFoundation//SAConst.swift {
// Pod/Classes/SAFoundation//SAFoundation.swift {
extension SAKit {
}
extension UIApplication {
	public class func openString(str: String) {
		open_string(str)
	}
}
extension String {
	public var wordCount: Int {
		get {
			return word_count
		}
		set(v) {
			word_count = v
		}
	}
	public func subRange(head: Int, _ tail: Int) -> String {
		return sub_range(head, _ : tail)
	}
	public func subBefore(sub: String) -> String {
		return sub_before(sub)
	}
	public func isEmail() -> Bool {
		return is_email()
	}
	public func removeWhitespace() -> String {
		return remove_whitespace()
	}
	public func decodeHtml() -> String {
		return decode_html()
	}
	public func toFilename() -> String {
		return to_filename()
	}
}
extension UserDefaults {
}
extension UIView {
	public func removeAllSubviews() {
		remove_all_subviews()
	}
	public func enableBorder(width border_width: CGFloat = -1, color: UIColor? = nil, radius: CGFloat = -1, is_circle: Bool = false) {
		enable_border(width : border_width, color: color, radius: radius, is_circle: is_circle)
	}
	public func insertGradient(colors:[AnyObject?], point1:CGPoint, point2:CGPoint) {
		insert_gradient(colors, point1: point1, point2: point2)
	}
	public func addShadow(size:CGSize) {
		add_shadow(size)
	}
}
extension NSString {
	public func filenameDoc(namespace: String? = nil) -> String {
		return filename_doc(namespace)
	}
	public func filenameLib(namespace: String? = nil) -> String {
		return filename_lib(namespace)
	}
	public func toFilename(namespace: String? = nil, directory: FileManager.SearchPathDirectory) -> String {
		return to_filename(namespace, directory: directory)
	}
	public func fileExistsDoc(namespace: String? = nil) -> Bool {
		return file_exists_doc(namespace)
	}
	public func fileExistsLib(namespace: String? = nil) -> Bool {
		return file_exists_lib(namespace)
	}
}
extension UIImageView {
	public func imageLoad(url: String?, clear: Bool = false) {
		image_load(url, clear: clear)
	}
}
extension NSData {
	public func toString(encoding:UInt = NSUTF8StringEncoding) -> String? {
		return to_string(encoding)
	}
}
extension NSMutableData {
	public func appendString(string: String) {
		append_string(string)
	}
}
extension UIFont {
	public class func printAll() {
		print_all()
	}
}
extension UIScrollView {
	public var contentX: CGFloat {
		get {
			return content_x
		}
		set(v) {
			content_x = v
		}
	}
	public var contentY: CGFloat {
		get {
			return content_y
		}
		set(v) {
			content_y = v
		}
	}
	public var animateX: CGFloat {
		get {
			return animate_x
		}
		set(v) {
			animate_x = v
		}
	}
	public var animateY: CGFloat {
		get {
			return animate_y
		}
		set(v) {
			animate_y = v
		}
	}
	public var contentW: CGFloat {
		get {
			return content_w
		}
		set(v) {
			content_w = v
		}
	}
	public var contentH: CGFloat {
		get {
			return content_h
		}
		set(v) {
			content_h = v
		}
	}
	public func pageReload() {
		page_reload()
	}
	public func pageChanged(page: UIPageControl) {
		page_changed(page)
	}
}
extension UIViewController {
	public func popTo(level:Int, animated:Bool = true) {
		pop_to(level, animated: animated)
	}
	public func pushIdentifier(controllerIdentifier: String, animated: Bool = true, hide_bottom: Bool? = nil) -> UIViewController? {
		return push_identifier(controllerIdentifier, animated: animated, hide_bottom: hide_bottom)
	}
	public func presentIdentifier(controllerIdentifier: String, animated: Bool = true) -> UIViewController? {
		return present_identifier(controllerIdentifier, animated: animated)
	}
}
extension UISearchBar {
	public func setTextImage(text: NSString, icon:UISearchBarIcon, attribute:SADictStrObj? = nil, state:UIControlState = .normal) {
		set_text_image(text, icon: icon, attribute: attribute, state: state)
	}
}
extension UIWebView {
	public func loadString(str:String) {
		load_string(str)
	}
}
extension UIDevice {
	public class func versionAtLeast(version: String) -> Bool {
		return version_at_least(version)
	}
}
extension SAViewController {
	public func saKeyboardWillShow(notification: NSNotification) {
		sa_keyboard_will_show(notification)
	}
	public func saKeyboardWillHide(notification: NSNotification) {
		sa_keyboard_will_hide(notification)
	}
	public func saKeyboardHeightChanged(height: CGFloat) {
		sa_keyboard_height_changed(height)
	}
}
extension SAHorizontalScrollController {
	public var delegateScroll: UIScrollViewDelegate? {
		get {
			return delegate_scroll
		}
		set(v) {
			delegate_scroll = v
		}
	}
	public func getWidth(index: Int) -> CGFloat {
		return get_width(index)
	}
	public func getTotal() -> CGFloat {
		return get_total()
	}
	public func getLabelIndex() -> Int {
		return get_label_index()
	}
}
extension SAMultipleTableController {
}
extension SATableDataSource {
	public var headerHeight: CGFloat  {
		get {
			return header_height
		}
		set(v) {
			header_height = v
		}
	}
	public var funcCell: ((NSIndexPath) -> UITableViewCell)!  {
		get {
			return func_cell
		}
		set(v) {
			func_cell = v
		}
	}
	public var funcHeader: ((Int) -> UIView?)?  {
		get {
			return func_header
		}
		set(v) {
			func_header = v
		}
	}
	public var funcHeight: ((NSIndexPath) -> CGFloat)?  {
		get {
			return func_height
		}
		set(v) {
			func_height = v
		}
	}
	public var funcSelect: ((NSIndexPath) -> Void)?  {
		get {
			return func_select
		}
		set(v) {
			func_select = v
		}
	}
	public var funcDeselect: ((NSIndexPath) -> Void)?  {
		get {
			return func_deselect
		}
		set(v) {
			func_deselect = v
		}
	}
	public var funcSelectSource: ((NSIndexPath, SATableDataSource) -> Void)?  {
		get {
			return func_select_source
		}
		set(v) {
			func_select_source = v
		}
	}
	public var funcDeselectSource: ((NSIndexPath, SATableDataSource) -> Void)?  {
		get {
			return func_deselect_source
		}
		set(v) {
			func_deselect_source = v
		}
	}
	public func indexAlphabet(array: Array<String>) -> Array<Array<String>> {
		return index_alphabet(array)
	}
}
extension LFDebug {
}
extension SACellTitleDetail {
	public var labelTitle: UILabel! {
		get {
			return label_title
		}
		set(v) {
			label_title = v
		}
	}
	public var labelDetail: UILabel! {
		get {
			return label_detail
		}
		set(v) {
			label_detail = v
		}
	}
}
// Pod/Classes/SAFoundation//SAFoundationWrapper.swift {
extension String {
}
extension UIView {
}
extension UIViewController {
}
// Pod/Classes/SAFoundation//SAKeychain.swift {
extension SAKeychain {
}
// Pod/Classes/SAFoundation//SAThemeManager.swift {
extension UITextView {
	public func removeObserverAlignment() {
		remove_observer_alignment()
	}
	public func removeObserverPlaceholder() {
		remove_observer_placeholder()
	}
	public func saReloadAlignMiddleVertical() {
		sa_reload_align_middle_vertical()
	}
	public func saTextEditBegan(notification: NSNotification) {
		sa_text_edit_began(notification)
	}
	public func saTextEditEnded(notification: NSNotification) {
		sa_text_edit_ended(notification)
	}
}
// Pod/Classes/SAFoundation//SATime.swift {
extension NSDate {
	public func toString(format:String) -> String? {
		return to_string(format)
	}
	public func toString() -> String? {
		return to_string()
	}
}
extension String {
	public func toDate(format:String = "dd/MM/yyyy") -> NSDate? {
		return to_date(format)
	}
}
