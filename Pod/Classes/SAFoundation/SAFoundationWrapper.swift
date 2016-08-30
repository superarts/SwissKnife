// ./SAFoundation//SAConst.swift {
// ./SAFoundation//SAFoundation.swift {
extension SAKit {
}
extension UIApplication {
}
extension String {
}
extension NSUserDefaults {
}
extension UIView {
}
extension NSString {
}
extension UIImageView {
}
extension NSData {
}
extension NSMutableData {
}
extension UIFont {
}
extension UIScrollView {
}
extension UIViewController {
}
extension UISearchBar {
}
extension UIWebView {
}
extension UIDevice {
}
extension SAViewController {
	public func lfKeyboardwillshow(notification: NSNotification) {
		lf_keyboardWillShow(notification)
	}
	public func lfKeyboardwillhide(notification: NSNotification) {
		lf_keyboardWillHide(notification)
	}
	public func lfKeyboardheightchanged(height: CGFloat) {
		lf_keyboardHeightChanged(height)
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
	public func lfActionreload() {
		lf_actionReload()
	}
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
// ./SAFoundation//SAKeychain.swift {
extension SAKeychain {
}
// ./SAFoundation//SAThemeManager.swift {
extension UITabBarController {
}
extension UIView {
}
extension UILabel {
}
extension UITextField {
}
extension UIScrollView {
}
extension UIBarItem {
}
extension UIButton {
}
extension UITextView {
}
// ./SAFoundation//SATime.swift {
extension NSDate {
}
extension String {
}