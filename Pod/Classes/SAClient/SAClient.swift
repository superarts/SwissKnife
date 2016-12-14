import Foundation
import UIKit

//	client
public struct SAREST {
	public static let domain = "LRestKit"
	public struct error {
		public static let invalid_parameter = 10000001
		public static let empty_response = 10000002
	}
	public struct content {
		public static let json = "application/json"
		public static let form = "multipart/form-data"
	}
	public enum HTTPMethod: String {
		case Get = "GET"
		case Put = "PUT"
		case Post = "POST"
		case Delete = "DELETE"
	}
	public struct method {
		public static let get = HTTPMethod.Get
		public static let put = HTTPMethod.Put
		public static let post = HTTPMethod.Post
		public static let delete = HTTPMethod.Delete
	}
	public enum ConnectionClass {
		case nsurlSession
		case nsurlConnection
	}
	public struct cache {
		public enum Policy {
			case none
			case cacheThenNetwork
		}
	}
	public struct pagination {
		public enum Method {
			case none
			case lastID
			case page
		}
	}
	public struct ui {
		public enum Load {
			case none
			case reload
			case more
		}
		public enum Reload {
			case none
			case first
			case always
		}
	}
}

open class SARESTClient<T: SAModel>: NSObject, URLSessionDataDelegate, URLSessionTaskDelegate {
	open var paths: [String]?		//	to support results like ["user": ["username"="1"], "succuss" = 1]
	open var subpaths: [String]?		//	to support ["users": [ [_source: ["username"="1"] ] ], "success" = 1]
	open var path: String? {			
		get {
			if let paths = paths , paths.count > 0 {
				return paths[0]
			}
			return nil
		}
		set(str) {
			if let s = str {
				paths = [s]
			} else {
				paths = nil
			}
		}
	}
	open var text: String?
	open var show_error = false
	open var content_type: String = SAREST.content.json
	open var connection_class: SAREST.ConnectionClass = .nsurlSession
	open var method: SAREST.HTTPMethod = .Get
	open var root: String!
	open var api: String!
	open var parameters: SADictStrObj?
	open var func_error: ((NSError) -> Void)?					//	generic error handler
	open var func_model: ((T?, NSError?) -> Void)?				//	parse to model
	open var func_array: ((Array<T>?, NSError?) -> Void)?		//	parse to array
	open var func_dict: ((SADictStrObj?, NSError?) -> Void)?		//	raw dictionary
	open var response: HTTPURLResponse?
	open var credential: URLCredential?
	open var cache_policy: SAREST.cache.Policy = .none
	open var form_data: [Data]?
	open var form_keys: SAArrayStr = ["file", "file1", "file2"]
	open var form_boundary: String = "---------------------------14737809831466499882746641449"		//"Boundary-\(NSUUID().UUID().UUIDString)"

	public init(api url: String, parameters param: SADictStrObj? = nil) {
		api = url
		parameters = param
	}

	//	TODO: create a protocol
	open func reload_authentication() {
		//	override me
	}
	open func text_show() {
		//	override mes
	}
	open func text_hide() {
		//	override me
	}
	open func error_show(_ error: NSError) {
		//	override mes
	}
	open func reload_api() -> String {
		var api_reloaded = api
		if method.rawValue == "GET" && parameters != nil {
			if (api_reloaded?.include("?"))! {
				api_reloaded = api_reloaded! + "&"
			} else {
				api_reloaded = api_reloaded! + "?"
			}

			//	TODO: encoding
			for (key, value) in parameters! {
				if value is String {
					api_reloaded = api_reloaded! + key + "=" + String(value as! String) + "&"
				} else if value is Int {
					api_reloaded = api_reloaded! + key + "=" + String(value as! Int) + "&"
				} else {
					SA.log("WARNING unknown parameter type", value)
				}
			}
			api_reloaded = api_reloaded?.sub_range(0, -1)
			//SA.log(api_reloaded, parameters)
		}
		return api_reloaded!
	}
	open func init_request(_ api: String) -> NSMutableURLRequest? {
		let url = URL(string: root + api)!
		let request = NSMutableURLRequest(url: url)
		request.httpMethod = method.rawValue
		if content_type == SAREST.content.form {
			let boundary = form_boundary
			request.httpBody = form_body(parameters, array_data:form_data)
			request.setValue(SAREST.content.json, forHTTPHeaderField:"Accept")
			request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
			if let data = request.httpBody {
				request.setValue(String(data.count), forHTTPHeaderField: "Content-Length")
			}
			SA.log("body length", request.httpBody?.count as AnyObject?)
			//SA.log("request", request)
			//SA.log("headers", request.allHTTPHeaderFields)
			//SA.log("method", request.HTTPMethod)
		} else if content_type == SAREST.content.json {
			request.addValue(content_type, forHTTPHeaderField:"Content-Type")
			request.addValue(content_type, forHTTPHeaderField:"Accept")

			//SA.log("REST method", method.rawValue)
			//SA.log("REST param", parameters)
			if method != SAREST.method.get && parameters != nil {

				var error_ret: NSError?
				let body: Data?
				do {
					body = try JSONSerialization.data(withJSONObject: parameters!, options: [])
				} catch let error as NSError {
					error_ret = error
					body = nil
				}
				//	SA.log("REST body", NSString(data: body!, encoding: NSUTF8StringEncoding))
				if error_ret != nil {
					error_ret = NSError(domain: SAREST.domain, code: SAREST.error.invalid_parameter, userInfo:[NSLocalizedDescriptionKey: "LRestKit: invalid parameters"])
					if show_error == true {
						error_show(error_ret!)
					}
					if let f = func_model {
						f(nil, error_ret)
					}
					if let f = func_array {
						f(nil, error_ret)
					}
					if let f = func_dict {
						f(nil, error_ret)
					}
					if let f = func_error {
						f(error_ret!)
					}
					return nil
				}
				request.httpBody = body
			}
		} else {
			SA.log("WARNING unknown content type", content_type as AnyObject?)
		}
        //  add credential manually
        /*
        if let authoritazion = String(format:"%@:%@", "icomplain_api", "password").dataUsingEncoding(NSUTF8StringEncoding) {
            let basic = String(format:"Basic %@", authoritazion.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength))
            request.setValue(basic, forHTTPHeaderField:"Authorization")
        }
        */
        return request
	}
	open var connection: NSURLConnection?
	open var task: URLSessionDataTask?
	open func execute() {
        var cache_loaded = false
		let api_reloaded = reload_api()
		if self.cache_policy == .cacheThenNetwork {
			let filename = self.get_filename(api_reloaded)
			if let data = try? Data(contentsOf: URL(fileURLWithPath: filename)) {
				//SA.log("CACHE loaded")
				//SA.dispatch() { }
                cache_loaded = true
				self.execute_data(data)
                //  TODO: save content hash and execute_data only if downlaoded
                //  content is new
			}
		}
		if let request = init_request(api_reloaded) {
			print(request)
			if text != nil && !cache_loaded {
				text_show()
			}
			//	TODO: change data and error to optional - done, need more debugging
			let func_done = {
				(response: URLResponse?, data: Data?, error: NSError?) -> Void in

				var error_ret: NSError? = error
				if self.text != nil && !cache_loaded {
					self.text_hide()
				}

				let resp = response as! HTTPURLResponse?
				self.response = resp
				if error != nil {
					//	SA.log("CLIENT error", error)
				} else if resp == nil {
					//	SA.log("url empty response", data)
					error_ret = NSError(domain: SAREST.domain, code: SAREST.error.empty_response, userInfo:[NSLocalizedDescriptionKey: "LRestKit: empty response"])
				} else if resp!.statusCode < 200 || resp!.statusCode >= 300 {
					//	SA.log("url failed", data?.to_string())
					let code = resp!.statusCode
					var info = [NSLocalizedDescriptionKey: HTTPURLResponse.localizedString(forStatusCode: code)]
					if let str = data?.to_string() {
						//	TODO: this is a temporary solution
						info["LRestClientResponseData"] = str
					}
					error_ret = NSError(domain: SAREST.domain, code: code, userInfo:info)
				} else {
					if self.cache_policy != .none {
						let filename = self.get_filename(api_reloaded)
						try? data?.write(to: URL(fileURLWithPath: filename), options: [.atomic])
						SA.log("CACHE saved")
					}
					self.execute_data(data!)
				}
				if error_ret != nil {
					if self.show_error == true {
						self.error_show(error_ret!)
					}
					if let f = self.func_model {
						f(nil, error_ret)
					}
					if let f = self.func_array {
						f(nil, error_ret)
					}
					if let f = self.func_dict {
						f(nil, error_ret)
					}
					if let f = self.func_error {
						f(error_ret!)
					}
				}
			}

			if connection_class == .nsurlSession {
				let config = URLSessionConfiguration.default
				let session = Foundation.URLSession(configuration:config, delegate:self, delegateQueue:OperationQueue.main)
				//task = session.dataTaskWithRequest(request, completionHandler:nil)
				task = session.dataTask(with: request as URLRequest) {
					(data, response, error) -> Void in
					SA.log("SESSION response", response)
					SA.log("SESSION error", data?.toString())
					if let error = error as? NSError, error.code == -999 {
						//SA.log("SESSION cancelled")
					} else if let error = error as? NSError {
						func_done(response, data, error)
					}
				}
				task!.resume()
			} else if connection_class == .nsurlConnection {
				let delegate = SARestConnectionDelegate()
				delegate.credential = credential
				delegate.func_done = func_done
				//	XXX: NSURLConnection support will be removed when iOS 8 support is stopped
				connection = NSURLConnection(request:request as URLRequest, delegate:delegate, startImmediately:true)
			}

			//SA.log("CONNECTION started", connection!)
			//SA.log("REQUEST headers", request.allHTTPHeaderFields)
            /*
            let url = request.URL
            let space = NSURLProtectionSpace(host:url.host,
                port:url.port.integerValue,
                protocol:url.scheme,
                realm:nil, 
                authenticationMethod:NSURLAuthenticationMethodHTTPBasic)
            NSURLCredentialStorage.sharedCredentialStorage.setDefaultCredential(self.credential!,
                forProtectionSpace:space)
            */
		} else {
			SA.log("WARNING SARESTClient", "empty request" as AnyObject?)
		}
	}
	open func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
		SA.log("SESSION invalid", error as AnyObject?)
	}
	open func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler handler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
		//SA.log("SESSION challenge", challenge)
		if let crt = credential {
			handler(.useCredential, crt)
		} else {
			handler(.performDefaultHandling, nil)
		}
	}
	open func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
		SA.log("SESSION finished")
	}
    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
		SA.log("TASK data received")
	}
	open func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler handler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
		SA.log("TASK challenge", challenge)
		if let crt = credential {
			handler(.useCredential, crt)
		}
		return
		/*
		if challenge.previousFailureCount > 0 {
			//SA.log("challenge cancelled")
			challenge.sender.cancelAuthenticationChallenge(challenge)
		} else if let credential = credential {
			//SA.log("challenge added")
			challenge.sender.useCredential(credential, forAuthenticationChallenge:challenge)
		} else {
			SA.log("REST connection will challenge", connection)
		}
		*/
	}
	open func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		SA.log("TASK error", error as AnyObject?)
	}
	open func cancel() {
		connection?.cancel()
		task?.cancel()
	}
    deinit {
        //SA.log("CLIENT deinit", self)
    }

	open func get_filename(_ api: String) -> String {
		var param_hash = self.parameters?.description.hash
		if param_hash == nil {
			param_hash = 0
		}
		let filename = String(format:"%@-%@-%i.xml", 
			self.root.to_filename(), api.to_filename(), param_hash!)
		return filename.to_filename(directory: .cachesDirectory)
	}
	open func execute_data(_ data: Data!) {
		var error: NSError?
		//let s = NSString(data: data, encoding: NSUTF8StringEncoding)
		let cls = T.self
		//SA.log("data", s)
		//	TODO: call func_error if error araises; this implementation just
		//	work, better to utilize try / cache in Swift 2.0 more elegantly.
		if let func_model = func_model {
			var obj: T?
			do {
    			var dict = try JSONSerialization.jsonObject(with: data, options: []) as? SADictStrObj
    			//	TODO: support multi-layer path (already implemented in func_array)
    			if let path = self.path {
    				if let dict_tmp = dict?[path] as? SADictStrObj {
    					dict = dict_tmp
    				}
    			}
				obj = cls.init(dict: dict)
			} catch let e as NSError {
				error = e
			}
			func_model(obj, error)
		}
		if let func_array = self.func_array {
			var array: [SADictStrObj]?
			if let paths = self.paths {
				do {
					var obj: Any = try JSONSerialization.jsonObject(with: data, options: [])
					for path in paths {
						if let obj_new: AnyObject = (obj as? SADictStrObj)?[path] {
							obj = obj_new	//(obj as! SADictStrObj)[path]!
						}
					}
					array = obj as? [SADictStrObj]
				} catch let e as NSError {
					error = e
				}
			} else {
				do {
					let array_json = try JSONSerialization.jsonObject(with: data, options: []) as? Array<SADictStrObj>
    				array = array_json
				} catch let e as NSError {
					error = e
				}
			}
			if let array = array {
				var array_obj: Array<T> = []
				for a_dict in array { 
					var dict = a_dict
					if let subpaths = self.subpaths {
						for subpath in subpaths {
							dict = dict[subpath] as! SADictStrObj	//	TODO: subpath checking
						}
					}
					let obj = cls.init(dict: dict)
					array_obj.append(obj)
				}
				func_array(array_obj, error)
			} else {
				func_array([], error)
			}
		}
		if let func_dict = self.func_dict {
			//	FIXME: this is an example to show how ugly the swift 2.0 code can be :(
			//let dict = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &error) as SADictStrObj
			var dict: SADictStrObj?
			do {
				dict = try JSONSerialization.jsonObject(with: data, options: []) as? SADictStrObj
			} catch let e as NSError {
				error = e
			}
			func_dict(dict, error)
		}
	}

	open func form_append(_ body: NSMutableData, key: String, value: String) {
		let boundary = form_boundary
		body.append_string("--\(boundary)\r\n")
		body.append_string("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
		body.append_string("\(value)\r\n")
	}
	open func form_append_dict(_ body: NSMutableData, param: SADictStrObj, prefix: String = "") {
		for (key, value) in param {
			var key_nested = key
			if prefix != "" {
				key_nested = prefix + "[" + key + "]"
			}
			if let array = value as? Array<AnyObject> {
				for item in array {
					form_append(body, key:key_nested + "[]", value:item.description)
				}
			} else if let dict = value as? SADictStrObj {
				form_append_dict(body, param:dict, prefix:key_nested)
			//} else if value is Int || value is Float || value is Double {
			//	form_append(body, key:key_nested, value:value)
			} else {
				form_append(body, key:key_nested, value:value.description)
			}
			//SA.log(key, value.description)
		}
	}
	open func form_body(_ parameters: [String: AnyObject]?, array_data: [Data]?) -> Data {
		let boundary = form_boundary
		let body = NSMutableData()

		//body.append_string("\r\ntag_ids[]=134&tag_ids[]=4\r\n")
		if let param = parameters {
			form_append_dict(body, param:param)
		}
		//SA.log("body", body.toString() as? AnyObject)

		if let array = array_data {
			var index = 0
			for data in array {
				let filePathKey = form_keys[index]
				let filename = "image" + String(index) + ".jpg"
				let mimetype = "image/jpeg"

				body.append_string("\r\n--\(boundary)\r\n")
				body.append_string("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(filename)\"\r\n")
				body.append_string("Content-Type: \(mimetype)\r\n\r\n")
				body.append(data)
				body.append_string("\r\n")
				index += 1
			}
		}

		body.append_string("--\(boundary)--\r\n")
		//SA.log("body", body.toString() as? AnyObject)
		return body as Data
	}
}

open class SARestConnectionDelegate: NSObject {

	open var func_done: ((URLResponse?, Data?, NSError?) -> Void)?   //  TODO: make response/data non-nullable
	open var credential: URLCredential?
	open var response: URLResponse?
	open var data: NSMutableData = NSMutableData()

	open func connection(_ connection: NSURLConnection, willSendRequestForAuthenticationChallenge challenge: URLAuthenticationChallenge) {
		if challenge.previousFailureCount > 0, let sender = challenge.sender {
			SA.log("challenge cancelled")
			sender.cancel(challenge)
		} else if let credential = credential, let sender = challenge.sender {
			SA.log("challenge added")
			sender.use(credential, for:challenge)
		} else {
			SA.log("REST connection will challenge", connection)
		}
	}
	open func connection(_ connection: NSURLConnection, didReceiveResponse a_response: URLResponse) {
		//SA.log("CONNECTION response", response)
		response = a_response
	}
	open func connection(_ connection: NSURLConnection, didReceiveData data_received: Data) {
		//SA.log("CONNECTION data", data.length)
		data.append(data_received)
	}
	open func connectionDidFinishLoading(_ connection: NSURLConnection) {
		//SA.log("CONNECTION finished", connection)
		//SA.log("CONNECTION finished", data.to_string())
		if func_done != nil {
			func_done!(response, data as Data, nil)
		}
	}
	open func connection(_ connection: NSURLConnection, didFailWithError error: NSError) {
		//SA.log("CONNECTION failed", error)
		if let func_done = func_done {
			func_done(response, data as Data, error)
		}
	}
	deinit {
		//SA.log("DELEGATE deinit", self)
	}
}

//	model

open class SAModel: NSObject {
  
	//	public & reserved
    //public var id: Int = 0
    open var id: String = ""
	open var raw: SADictStrObj?

	public struct prototype {
		public static var indent: Int = 0
	}

	//	override this function to disable this log. TODO: find a better way.
	open func log_description_not_found(_ value: AnyObject) {
		SA.log("WARNING name 'description' is a reserved word", value)
	}
    required public init(dict: Dictionary<String, AnyObject>?) {
        super.init()
		raw = dict
		if dict != nil {
			for (key, value) in dict! {
				//	SA.log(key, value)
				if key == "description" {
					log_description_not_found(value)
				} else if value is NSNull {
					//SA.log("WARNING null value", key)
				} else {
					//	TODO: not working for Int? and Int! in 6.0 GM
					if responds(to: NSSelectorFromString(key)) && key != "keys" {
						//SA.log(key, value)
						if value is [String: AnyObject] || value is [AnyObject] {
							//	SA.log("reload", key)
							let type: Mirror = Mirror(reflecting:self)
							for child in type.children {
								if let label = child.label , label == key
								{
									var type = String(describing: type(of: (child.value) as AnyObject))
									type = type.replacingOccurrences(of: "Optional<", with: "", options: NSString.CompareOptions.literal, range: nil)
									type = type.replacingOccurrences(of: "Array<", with: "", options: NSString.CompareOptions.literal, range: nil)
									type = type.replacingOccurrences(of: ">", with: "", options: NSString.CompareOptions.literal, range: nil)

									let bundle = Bundle(for: type(of: self))
									if let name = bundle.infoDictionary?[kCFBundleNameKey as String] as? String {
										type = name + "." + type
									}

									setValue(value, forKey:key)
									reload(key, type: type)
									break
								}
							}
						} else {
							setValue(value, forKey:key)
						}
					} else {
						/*
    					SA.log("WARNING model ignored", key)
    					SA.log("\tdata", dict)
    					SA.log("\tmodel", self)
    					SA.log("WARNING model ignored end of", key)
						*/
					}
					//else { SA.log("no selector", key) }
				}
			}
		} else {
			//SA.log("SAModel empty dict")
		}
    }

	convenience init(filename: String) {
		let dict = NSDictionary(contentsOfFile: filename)
		//SA.log(filename, dict)
		self.init(dict: dict as? SADictStrObj)
	}
	open func save(_ filename: String, atomically: Bool = true) -> Bool {
		/*
		let data = NSKeyedArchiver.archivedDataWithRootObject(dictionary)
		do {
			try data.writeToFile(filename, options:[])
			SA.log("save succesx", filename)
		} catch let e as NSError {
			SA.log("save failed", e)
		}
		if let dict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSDictionary {
			let success = dict.writeToFile(filename, atomically: atomically)
			SA.log("dict", dict)
			SA.log("saving success", success)
			return success
		}
		SA.log("saving success failed: not valid dictionary")
		*/
		let success = (dictionary as NSDictionary).write(toFile: filename, atomically: atomically)
		//SA.log("saving success", success)
		return success
	}
	open func reload(_ key: String, type: String) {
		for (a_key, value) in dictionary {
			if let dict_parameter = value as? Dictionary<String, AnyObject> {
				if a_key == key {
					let a_class = NSClassFromString(type) as! SAModel.Type
					let obj = a_class.init(dict: dict_parameter)
					setValue(obj, forKey:key)
				}
			} else if let array_parameter = value as? Array<AnyObject> {
				if a_key == key {
					var array_new: Array<AnyObject> = []
					for obj in array_parameter {
						if let dict_parameter = obj as? Dictionary<String, AnyObject> {
							//SA.log(key, obj: dict_parameter)
							let a_class = NSClassFromString(type) as! SAModel.Type
							let obj_new = a_class.init(dict: dict_parameter)
							//SA.log(key, obj: obj_new)
							array_new.append(obj_new)
						}
					}
					setValue(array_new, forKey:key)
				}
			}
		}
	}

	override open func value(forUndefinedKey key: String) -> Any? {
		return nil
	}
    open func dictionary(_ keys: [String]) -> Dictionary<String, AnyObject> {
        var dict: Dictionary<String, AnyObject> = [:]
        for key in keys {
            if let value: AnyObject = value(forKeyPath: key) as AnyObject? {
				if let v = value as? SAModel {
					dict[key] = v.dictionary as AnyObject?
				} else {
					dict[key] = value
				}
            }
        }
        return dict
    }
	//	TODO: refactor me - should be method instead of property
	open var keys: [String] {
        var array = [String]()
        var count: CUnsignedInt = 0
		let properties: UnsafeMutablePointer<objc_property_t?> = class_copyPropertyList(object_getClass(self), &count)
  
		var c: AnyClass! = object_getClass(self)
		loop: while c != nil {
			//SA.log("---- class", NSStringFromClass(c))
			var ct: CUnsignedInt = 0
			let prop: UnsafeMutablePointer<objc_property_t?> = class_copyPropertyList(c, &ct)
			for i in 0 ..< Int(ct) {
                if let key = NSString(cString: property_getName(prop[i]), encoding: String.Encoding.utf8.rawValue) {
    				if key == "dictionary" {
    					//SA.log("WARNING model: this condition is not ideal")
    					break loop
    				}
					/*
    				if let value: AnyObject? = valueForKey(key as String) where key != "raw" {
						array.append(key as String)
    				}
					*/
                }
			}
			//	TODO: apple's bug
			if NSStringFromClass(c) == "NSObject" {
				//SA.log("break")
				break
			}
			/*
			if NSStringFromClass(c).include("SAModel") {
				break
			}
			*/
			c = class_getSuperclass(c)
		}

        for i in 0 ..< Int(count) {
            if let key = NSString(cString: property_getName(properties[i]), encoding: String.Encoding.utf8.rawValue) as? String {
				//SA.log(key, valueForKey(key))
				if let _ = value(forKey: key) {
					array.append(key)
				}
			}
        }
        return array
	}
    //  Nesting is supported. You can also use dictionary(keys) to make dictionary from selected keys.
    open var dictionary: Dictionary<String, AnyObject> {
        var dict: Dictionary<String, AnyObject> = [:]
        var count: CUnsignedInt = 0
		let properties: UnsafeMutablePointer<objc_property_t?> = class_copyPropertyList(object_getClass(self), &count)
   
		var c: AnyClass! = object_getClass(self)
		loop: while c != nil {
			//	SA.log("---- class", NSStringFromClass(c))
			var ct: CUnsignedInt = 0
			let prop: UnsafeMutablePointer<objc_property_t?> = class_copyPropertyList(c, &ct)
			for i in 0 ..< Int(ct) {
                if let key = NSString(cString: property_getName(prop[i]), encoding: String.Encoding.utf8.rawValue) {
					if key == "dictionary" || key == "keys" || key == "description" {
    					//SA.log("WARNING model: this condition is not ideal")
						break loop
    				}
					if let value: AnyObject? = value(forKey: key as String) as AnyObject?? , key != "raw" {
						dict[key as String] = value
    				}
                }
			}
			//	TODO: apple's bug
			if NSStringFromClass(c) == "NSObject" {
				break
			}
			/*
			if NSStringFromClass(c).include("SAModel") {
				break
			}
			*/
			c = class_getSuperclass(c)
		}

        for i in 0 ..< Int(count) {
            if let key = NSString(cString: property_getName(properties[i]), encoding: String.Encoding.utf8.rawValue) as? String {
				if key == "description" || key == "keys" || key == "dictionary" {
					continue
				}
				if let value: AnyObject? = value(forKey: key) as AnyObject?? {
					if let v = value as? SAModel {
						dict[key] = v.dictionary as AnyObject?
					} else if let a = value as? [SAModel] {
						var array = [AnyObject]()
						for v in a {
							array.append(v.dictionary as AnyObject)
						}
						dict[key] = array as AnyObject?
					} else {
						dict[key] = value
					}
				}
			}
        }
        return dict
    }
   
    override open var description: String {
        var s = NSStringFromClass(type(of: self))
        s = NSString(format: "%@ (%p): [\r", s, self) as String
		SAModel.prototype.indent += 1
        for (key, value) in dictionary {
			if key == "raw" {
				continue
			}
			s = append_indent(s)
			if let array = value as? Array<AnyObject> {
				s = s.appendingFormat("%@: [\r", key)
				SAModel.prototype.indent += 1
				for obj in array {
					s = append_indent(s)
					s = s.appendingFormat("%@\r", obj.description)
				}
				SAModel.prototype.indent -= 1
				s = append_indent(s)
				s = s + "]\r"
			}
			else if value is Int || value is Float {
				s = s.appendingFormat("%@: %@\r", key, value.description)
			} else {
				s = s.appendingFormat("%@: '%@'\r", key, value.description)
			}
        }
		SAModel.prototype.indent -= 1
		s = append_indent(s)
        s = s + "]"
        return s
    }

	open func append_indent(_ str: String) -> String {
		var s = str
		for _ in 0 ..< SAModel.prototype.indent {
			//s = s.stringByAppendingString("\t")
			s = s + "    "
		}
		return s
	}
}

open class SAAutosaveModel: SAModel {
	//	autosave only makes sense when a back-end service is enabled e.g. Parse, see LFProfile

	open var lf_version: String? = Bundle.main.infoDictionary?["CFBundleVersion"] as? String

	open static let autosave_prefix = "Autosave_"		//	TODO
	open func autosave_filename() -> String {
        var filename = NSStringFromClass(type(of: self))
		filename = filename.replacingOccurrences(of: ".", with: "_", options:[], range: nil)
		filename = SAAutosaveModel.autosave_prefix + filename + ".xml"
		return filename.filename_doc()
	}
	//	publish
	//		true: publish profile (debug build only)
	//		false: download profile
	//	reload_immediately
	//		true: overwrite profile immediately after it's downloaded (default)
	//		false: profile will be available from next app launch (not implemented)
	convenience init(publish: Bool, reload_immediately: Bool = true) {
		//	TODO: how to call autosave_filename() instead? is double-init a must?
        var filename = NSStringFromClass(type(of: self))
		filename = filename.replacingOccurrences(of: ".", with: "_", options:[], range: nil)
		filename = SAAutosaveModel.autosave_prefix + filename + ".xml"
		filename = filename.filename_doc()

		self.init(filename: filename)
		if publish {
			autosave_publish()
		} else {
			autosave_reload()
		}
	}
	open func autosave_publish() {
		SA.log("TODO save", "override me" as AnyObject?)
	}
	open func autosave_reload() {
		SA.log("TODO load", "override me" as AnyObject?)
	}
}

/*
class LRestObject: SAModel {
	var items: [LRestObject] = []	//	impossible to make it dynamic?
	let client = SARESTClient<SAModel>()
}
*/

public protocol SATableClient {
	func reload()
	func load_more()
	//func reload_table()
	//var func_reload: ([SAModel] -> Void)? { get set }
	//var func_error: (NSError -> Void)? { get set }
	var func_done: ((Void) -> Void)? { get set }		//	rename me
	var last_loaded: Int { get set }
	var pagination_index: Int { get set }
}

open class SAArrayClient<T: SAModel>: SARESTClient<T>, SATableClient {
	open var items: Array<T> = Array<T>()
	open var func_reload: (([T]) -> Void)?
	//var func_error: (NSError -> Void)?
	open var func_done: ((Void) -> Void)?
	open var is_loaded = false
	open var is_loading = false

	open var last_loaded = 0
	open var pagination_method: SAREST.pagination.Method = .none
	open var pagination_key: String!
	open var pagination_index = 0

	public override init(api url: String, parameters param: SADictStrObj? = nil) {
		super.init(api:url, parameters:param)
		show_error = true
	}
	open func reload() {
		pagination_index = 0
		parameters?.removeValue(forKey: pagination_key)
		items.removeAll()
		load_more()
	}
	open func load_more() {
		if is_loading {
			return
		}
		if pagination_method == .lastID {
			if pagination_index != 0 {
				if let last = items.last {
					SA.log("last", last.id as AnyObject?)
					if parameters != nil {
						parameters![pagination_key] = last.id as AnyObject?
					} else {
						parameters = [pagination_key: last.id as AnyObject]
					}
				}
			}
		}
		is_loading = true
		is_loaded = false
		func_array = {
			(results: [T]?, error: NSError?) -> Void in
			if let objs = results {
				//	only keep the last loaded data
				if self.is_loaded == false {
					self.is_loaded = true
				} else {
					for _ in 0 ..< self.last_loaded {
						self.items.removeLast()
					}
					//SA.log("last items removed", self.last_loaded)
				}

				if objs.count > 0 {
					self.pagination_index += 1
				}
				self.last_loaded = objs.count
				self.items += objs
				if let f = self.func_reload { f(self.items) }
			} else if let f = self.func_error, let error = error {
				f(error)
			}
			if let f = self.func_done { f() }
			self.is_loading = false
		}
		execute()
	}
	/*
	func reload_table() {
		reload()
		if let f = func_reload { f(items) }
		if let f = func_done { f() }
	}
	*/
}

open class SARESTTableController: SATableController {
	open var client: SATableClient!
	open var reload_table: SAREST.ui.Reload = .first
	open var refresh_reload: UIRefreshControl?
	open var refresh_more: UIRefreshControl?
	open var pull_down: SAREST.ui.Load = .none
	open var pull_up: SAREST.ui.Load = .none
	open var func_done: ((Void) -> Void)?

	open override func awakeFromNib() {
		super.awakeFromNib()
		/*
		let c = ICMyComplaintClient<ICComplaintModel>()
		c.func_reload = {
			(complaints) -> Void in
			self.reload_table(complaints)
		}
		client = c
		*/
	}
	open override func viewDidLoad() {
		super.viewDidLoad()
		reload_refresh()
		if reload_table != .none {
			client_reload()
		}
	}
	open override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if reload_table == .always {
			client_reload()
		}
	}

	open func reload_refresh() {
		//	TODO: refactor
		if refresh_reload != nil {
			refresh_reload!.removeFromSuperview()
			refresh_reload = nil
		}
		if refresh_more != nil {
			table.perform("bottomRefreshControl", value:nil)
			refresh_more = nil
		}
		if pull_down == .reload {
			refresh_reload = UIRefreshControl()
			refresh_reload!.perform("triggerVerticalOffset", value:60 as AnyObject?)
			refresh_reload!.addTarget(self, action: #selector(SARESTTableController.client_reload), for: .valueChanged)
			table.addSubview(refresh_reload!)
		} else if pull_down == .more {
			refresh_reload = UIRefreshControl()
			refresh_reload!.perform("triggerVerticalOffset", value:60 as AnyObject?)
			refresh_reload!.addTarget(self, action: #selector(SARESTTableController.client_more), for: .valueChanged)
			table.addSubview(refresh_reload!)
		}
		//	XXX: pod integration
		if pull_up == .more && table.responds(to: Selector("bottomRefreshControl")) {
			refresh_more = UIRefreshControl()
			refresh_more!.perform("triggerVerticalOffset", value:60 as AnyObject?)
			refresh_more!.addTarget(self, action:#selector(SARESTTableController.client_more), for:.valueChanged)
			table.perform("bottomRefreshControl", value:refresh_more!)
		}
		client.func_done = {
			self.refresh_end()
			if self.client.last_loaded == 0 && self.client.pagination_index != 0 {
				self.show_no_more_items()
			}
			if let f = self.func_done {
				f()
			}
		}
	}
	open func refresh_end() {
		if let refresh = refresh_reload , self.pull_down != .none {
			refresh.endRefreshing()
		}
		if let refresh = refresh_more , self.pull_up != .none {
			refresh.endRefreshing()
		}
	}
	open func client_reload() {
		client.reload()
	}
	open func client_more() {
		client.load_more()
	}
	open func clear() {
		source.counts = [0]
		source.table.reloadData()
	}
	open func show_no_more_items() {
		//	override me
	}
}

open class SALocalizable: SAAutosaveModel {
	open var lf_language: Item = Item()

	open class Item: NSObject {
		var array = [String]()
		open var str: String {
			if let index = SATheme.localization.language_current(nil) {
				return array[index]
			}
			return ""
		}
		open var STR: String {
			return str.uppercased()
		}
		/*
		open var Str: String {
			let s = str
			return s[0].uppercased() + s[1...s.length]
		}
		*/
		open var s: String {
			return str
		}
		open var S: String {
			return STR
		}
	}
	public required init(dict: SADictStrObj?) {
		super.init(dict: dict)
		for language in SATheme.localization.languages {
			lf_language += language.rawValue
		}
	}
    open override var dictionary: Dictionary<String, AnyObject> {
		var dict = [String: AnyObject]()
		for key in keys {
			if let item = value(forKey: key) as? Item {
				dict[key] = item.array as AnyObject?
			}
		}
		return dict
	}
}

public func += (left: inout SALocalizable.Item, right: String) {
	left.array.append(right)
}