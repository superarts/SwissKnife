// Pod/Classes/SAClient//SAClient.swift {
extension SARESTClient {
	public var showError: Bool {
		get {
			return show_error
		}
		set(v) {
			show_error = v
		}
	}
	public var contentType: String  {
		get {
			return content_type
		}
		set(v) {
			content_type = v
		}
	}
	public var connectionClass: SAREST.ConnectionClass  {
		get {
			return connection_class
		}
		set(v) {
			connection_class = v
		}
	}
	public var funcError: ((NSError) -> Void)?					 {
		get {
			return func_error
		}
		set(v) {
			func_error = v
		}
	}
	public var funcModel: ((T?, NSError?) -> Void)?				 {
		get {
			return func_model
		}
		set(v) {
			func_model = v
		}
	}
	public var funcArray: ((Array<T>?, NSError?) -> Void)?		 {
		get {
			return func_array
		}
		set(v) {
			func_array = v
		}
	}
	public var funcDict: ((SADictStrObj?, NSError?) -> Void)?		 {
		get {
			return func_dict
		}
		set(v) {
			func_dict = v
		}
	}
	public var cachePolicy: SAREST.cache.Policy  {
		get {
			return cache_policy
		}
		set(v) {
			cache_policy = v
		}
	}
	public var formData: [NSData]? {
		get {
			return form_data
		}
		set(v) {
			form_data = v
		}
	}
	public var formKeys: SAArrayStr  {
		get {
			return form_keys
		}
		set(v) {
			form_keys = v
		}
	}
	public var formBoundary: String  {
		get {
			return form_boundary
		}
		set(v) {
			form_boundary = v
		}
	}
	public func reloadAuthentication() {
		reload_authentication()
	}
	public func textShow() {
		text_show()
	}
	public func textHide() {
		text_hide()
	}
	public func errorShow(error: NSError) {
		error_show(error)
	}
	public func reloadApi() -> String {
		return reload_api()
	}
	public func initRequest(api: String) -> NSMutableURLRequest? {
		return init_request(api)
	}
	public func getFilename(api: String) -> String {
		return get_filename(api)
	}
	public func executeData(data: NSData!) {
		execute_data(data)
	}
	public func formAppend(body: NSMutableData, key: String, value: String) {
		form_append(body, key: key, value: value)
	}
	public func formAppendDict(body: NSMutableData, param: SADictStrObj, prefix: String = "") {
		form_append_dict(body, param: param, prefix: prefix)
	}
	public func formBody(parameters: [String: AnyObject]?, array_data: [NSData]?) -> NSData {
		return form_body(parameters, array_data: array_data)
	}
}
extension SARestConnectionDelegate {
	public var funcDone: ((NSURLResponse?, NSData?, NSError!) -> Void)?    {
		get {
			return func_done
		}
		set(v) {
			func_done = v
		}
	}
}
extension SAModel {
	public func logDescriptionNotFound(value: AnyObject) {
		log_description_not_found(value)
	}
	public func appendIndent(str: String) -> String {
		return append_indent(str)
	}
}
extension SAAutosaveModel {
	public var lfVersion: String?  {
		get {
			return lf_version
		}
		set(v) {
			lf_version = v
		}
	}
	public func autosaveFilename() -> String {
		return autosave_filename()
	}
	public func autosavePublish() {
		autosave_publish()
	}
	public func autosaveReload() {
		autosave_reload()
	}
}
extension SATableClient {
}
extension SAArrayClient {
	public var funcReload: ([T] -> Void)? {
		get {
			return func_reload
		}
		set(v) {
			func_reload = v
		}
	}
	public var funcDone: (Void -> Void)? {
		get {
			return func_done
		}
		set(v) {
			func_done = v
		}
	}
	public var isLoaded: Bool {
		get {
			return is_loaded
		}
		set(v) {
			is_loaded = v
		}
	}
	public var isLoading: Bool {
		get {
			return is_loading
		}
		set(v) {
			is_loading = v
		}
	}
	public var lastLoaded: Int {
		get {
			return last_loaded
		}
		set(v) {
			last_loaded = v
		}
	}
	public var paginationMethod: SAREST.pagination.Method  {
		get {
			return pagination_method
		}
		set(v) {
			pagination_method = v
		}
	}
	public var paginationKey: String! {
		get {
			return pagination_key
		}
		set(v) {
			pagination_key = v
		}
	}
	public var paginationIndex: Int {
		get {
			return pagination_index
		}
		set(v) {
			pagination_index = v
		}
	}
	public func loadMore() {
		load_more()
	}
}
extension SARESTTableController {
	public var reloadTable: SAREST.ui.Reload  {
		get {
			return reload_table
		}
		set(v) {
			reload_table = v
		}
	}
	public var refreshReload: UIRefreshControl? {
		get {
			return refresh_reload
		}
		set(v) {
			refresh_reload = v
		}
	}
	public var refreshMore: UIRefreshControl? {
		get {
			return refresh_more
		}
		set(v) {
			refresh_more = v
		}
	}
	public var pullDown: SAREST.ui.Load  {
		get {
			return pull_down
		}
		set(v) {
			pull_down = v
		}
	}
	public var pullUp: SAREST.ui.Load  {
		get {
			return pull_up
		}
		set(v) {
			pull_up = v
		}
	}
	public var funcDone: (Void -> Void)? {
		get {
			return func_done
		}
		set(v) {
			func_done = v
		}
	}
	public func reloadRefresh() {
		reload_refresh()
	}
	public func refreshEnd() {
		refresh_end()
	}
	public func clientReload() {
		client_reload()
	}
	public func clientMore() {
		client_more()
	}
	public func showNoMoreItems() {
		show_no_more_items()
	}
}
extension SALocalizable {
	public var lfLanguage: Item  {
		get {
			return lf_language
		}
		set(v) {
			lf_language = v
		}
	}
}
// Pod/Classes/SAClient//SAClientWrapper.swift {
extension SARESTClient {
}
