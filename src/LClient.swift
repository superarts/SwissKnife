import Foundation
import UIKit

//	client
struct LRest {
	static let domain = "LRestKit"
	struct error {
		static let invalid_parameter = 10000001
		static let empty_response = 10000002
	}
	struct content {
		static let json = "application/json"
		static let form = "multipart/form-data"
	}
	enum HTTPMethod: String {
		case Get = "GET"
		case Put = "PUT"
		case Post = "POST"
		case Delete = "DELETE"
	}
	struct method {
		static let get = HTTPMethod.Get
		static let put = HTTPMethod.Put
		static let post = HTTPMethod.Post
		static let delete = HTTPMethod.Delete
	}
	enum ConnectionClass {
		case NSURLSession
		case NSURLConnection
	}
	struct cache {
		enum Policy {
			case None
			case CacheThenNetwork
		}
	}
	struct pagination {
		enum Method {
			case None
			case LastID
			case Page
		}
	}
	struct ui {
		enum Load {
			case None
			case Reload
			case More
		}
		enum Reload {
			case None
			case First
			case Always
		}
	}
}

class LRestClient<T: LFModel>: NSObject, NSURLSessionDataDelegate, NSURLSessionTaskDelegate {
	var paths: [String]?		//	to support results like ["user": ["username"="1"], "succuss" = 1]
	var subpaths: [String]?		//	to support ["users": [ [_source: ["username"="1"] ] ], "success" = 1]
	var path: String? {			
		get {
			if let paths = paths where paths.count > 0 {
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
	var text: String?
	var show_error = false
	var content_type = LRest.content.json
	var connection_class = LRest.ConnectionClass.NSURLSession
	var method = LRest.method.get
	var root: String!
	var api: String!
	var parameters: LTDictStrObj?
	var func_model: ((T?, NSError?) -> Void)?				//	parse to model
	var func_array: ((Array<T>?, NSError?) -> Void)?		//	parse to array
	var func_dict: ((LTDictStrObj?, NSError?) -> Void)?		//	raw dictionary
	var response: NSHTTPURLResponse?
	var credential: NSURLCredential?
	var cache_policy = LRest.cache.Policy.None
	var form_data: [NSData]?
	var form_keys = ["file", "file1", "file2"]
	var form_boundary = "---------------------------14737809831466499882746641449"		//"Boundary-\(NSUUID().UUID().UUIDString)"

	init(api url: String, parameters param: LTDictStrObj? = nil) {
		api = url
		parameters = param
	}

	//	TODO: create a protocol
	func reload_authentication() {
		//	override me
	}
	func text_show() {
		//	override mes
	}
	func text_hide() {
		//	override me
	}
	func error_show(error: NSError) {
		//	override mes
	}
	func reload_api() -> String {
		var api_reloaded = api
		if method.rawValue == "GET" && parameters != nil {
			if api_reloaded.contains("?") {
				api_reloaded = api_reloaded + "&"
			} else {
				api_reloaded = api_reloaded + "?"
			}

			//	TODO: encoding
			for (key, value) in parameters! {
				if value is String {
					api_reloaded = api_reloaded + key + "=" + String(value as! String) + "&"
				} else if value is Int {
					api_reloaded = api_reloaded + key + "=" + String(value as! Int) + "&"
				} else {
					LF.log("WARNING unknown parameter type", value)
				}
			}
			api_reloaded = api_reloaded.sub_range(0, -1)
			//LF.log(api_reloaded, parameters)
		}
		return api_reloaded
	}
	func init_request(api: String) -> NSMutableURLRequest? {
		var url = NSURL(string: root + api)!
		var request = NSMutableURLRequest(URL: url)
		request.HTTPMethod = method.rawValue
		if content_type == LRest.content.form {
			let boundary = form_boundary
			request.HTTPBody = form_body(parameters, array_data:form_data)
			request.setValue(LRest.content.json, forHTTPHeaderField:"Accept")
			request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
			if let data = request.HTTPBody {
				request.setValue(String(data.length), forHTTPHeaderField: "Content-Length")
			}
			LF.log("body length", request.HTTPBody?.length)
			//LF.log("request", request)
			//LF.log("headers", request.allHTTPHeaderFields)
			//LF.log("method", request.HTTPMethod)
		} else if content_type == LRest.content.json {
			request.addValue(content_type, forHTTPHeaderField:"Content-Type")
			request.addValue(content_type, forHTTPHeaderField:"Accept")

			//LF.log("REST method", method.rawValue)
			//LF.log("REST param", parameters)
			if method != LRest.method.get && parameters != nil {

				var error_ret: NSError?
				let body = NSJSONSerialization.dataWithJSONObject(parameters!, options: nil, error: &error_ret)
				//	LF.log("REST body", NSString(data: body!, encoding: NSUTF8StringEncoding))
				if error_ret != nil {
					error_ret = NSError(domain: LRest.domain, code: LRest.error.invalid_parameter, userInfo:[NSLocalizedDescriptionKey: "LRestKit: invalid parameters"])
					if show_error == true {
						error_show(error_ret!)
					}
					if func_model != nil {
						func_model!(nil, error_ret)
					}
					if func_array != nil {
						func_array!(nil, error_ret)
					}
					if func_dict != nil {
						func_dict!(nil, error_ret)
					}
					return nil
				}
				request.HTTPBody = body
			}
		} else {
			LF.log("WARNING unknown content type", content_type)
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
	var connection: NSURLConnection?
	var task: NSURLSessionDataTask?
	func execute() {
        var cache_loaded = false
		let api_reloaded = reload_api()
		if self.cache_policy == .CacheThenNetwork {
			let filename = self.get_filename(api_reloaded)
			if let data = NSData(contentsOfFile:filename) {
				//LF.log("CACHE loaded")
				//LF.dispatch() { }
                cache_loaded = true
				self.execute_data(data)
                //  TODO: save content hash and execute_data only if downlaoded
                //  content is new
			}
		}
		if let request = init_request(api_reloaded) {

			var error_ret: NSError?
			if text != nil && !cache_loaded {
				text_show()
			}
			//	TODO: change data and error to optional - done, need more debugging
			var func_done = {
				(response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in

				var error_ret: NSError? = error
				if self.text != nil && !cache_loaded {
					self.text_hide()
				}

				var resp = response as! NSHTTPURLResponse?
				self.response = resp
				if error != nil {
					//	LF.log("CLIENT error", error)
				} else if resp == nil {
					//	LF.log("url empty response", data)
					error_ret = NSError(domain: LRest.domain, code: LRest.error.empty_response, userInfo:[NSLocalizedDescriptionKey: "LRestKit: empty response"])
				} else if resp!.statusCode < 200 || resp!.statusCode >= 300 {
					//	LF.log("url failed", data?.to_string())
					let code = resp!.statusCode
					var info = [NSLocalizedDescriptionKey: NSHTTPURLResponse.localizedStringForStatusCode(code)]
					if let str = data?.to_string() {
						//	TODO: this is a temporary solution
						info["LRestClientResponseData"] = str
					}
					error_ret = NSError(domain: LRest.domain, code: code, userInfo:info)
				} else {
					if self.cache_policy != .None {
						let filename = self.get_filename(api_reloaded)
						data?.writeToFile(filename, atomically:true)
						LF.log("CACHE saved")
					}
					self.execute_data(data!)
				}
				if error_ret != nil {
					if self.show_error == true {
						self.error_show(error_ret!)
					}
					if self.func_model != nil {
						self.func_model!(nil, error_ret)
					}
					if self.func_array != nil {
						self.func_array!(nil, error_ret)
					}
					if self.func_dict != nil {
						self.func_dict!(nil, error_ret)
					}
				}
			}

			if connection_class == .NSURLSession {
				let config = NSURLSessionConfiguration.defaultSessionConfiguration()
				let session = NSURLSession(configuration:config, delegate:self, delegateQueue:NSOperationQueue.mainQueue())
				//task = session.dataTaskWithRequest(request, completionHandler:nil)
				task = session.dataTaskWithRequest(request) {
					(data, response, error) -> Void in
					//LF.log("SESSION response", response)
					if let error = error where error.code == -999 {
						//LF.log("SESSION cancelled")
					} else {
						func_done(response, data, error)
					}
				}
				task!.resume()
			} else if connection_class == .NSURLConnection {
				let delegate = LRestConnectionDelegate()
				delegate.credential = credential
				delegate.func_done = func_done
				connection = NSURLConnection(request:request, delegate:delegate, startImmediately:true)
			}

			//LF.log("CONNECTION started", connection!)
			//LF.log("REQUEST headers", request.allHTTPHeaderFields)
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
			LF.log("WARNING LClient", "empty request")
		}
	}
	func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
		LF.log("SESSION invalid", error)
	}
	func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler handler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
		LF.log("SESSION challenge", challenge)
		if let crt = credential {
			handler(.UseCredential, crt)
		}
	}
	func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
		LF.log("SESSION finished")
	}
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
		LF.log("TASK data received")
	}
	func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler handler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
		LF.log("TASK challenge", challenge)
		if let crt = credential {
			handler(.UseCredential, crt)
		}
		return
		/*
		if challenge.previousFailureCount > 0 {
			//LF.log("challenge cancelled")
			challenge.sender.cancelAuthenticationChallenge(challenge)
		} else if let credential = credential {
			//LF.log("challenge added")
			challenge.sender.useCredential(credential, forAuthenticationChallenge:challenge)
		} else {
			LF.log("REST connection will challenge", connection)
		}
		*/
	}
	func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
		LF.log("TASK error", error)
	}
	func cancel() {
		connection?.cancel()
		task?.cancel()
	}
    deinit {
        //LF.log("CLIENT deinit", self)
    }

	func get_filename(api: String) -> String {
		var param_hash = self.parameters?.description.hash
		if param_hash == nil {
			param_hash = 0
		}
		let filename = String(format:"%@-%@-%i.xml", 
			self.root.to_filename(), api.to_filename(), param_hash!)
		return filename.to_filename(directory: .CachesDirectory)
	}
	func execute_data(data: NSData!) {

		var error: NSError?
		let s = NSString(data: data, encoding: NSUTF8StringEncoding)
		let cls = T.self
		//LF.log("data", s)
		if let func_model = func_model {
			var dict = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as! LTDictStrObj?
			//	TODO: support multi-layer path (already implemented in func_array)
			if let path = self.path {
				if var dict_tmp = dict?[path] as? LTDictStrObj {
					dict = dict_tmp
				}
			}
			if error == nil {
				let obj = cls(dict: dict)
				func_model(obj, error)
			}
		}
		if let func_array = self.func_array {
			var array: [LTDictStrObj]?
			if let paths = self.paths {
				if var obj: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) {
					for path in paths {
						if let obj_new: AnyObject = (obj as? LTDictStrObj)?[path] {
							obj = obj_new	//(obj as! LTDictStrObj)[path]!
						}
					}
					array = obj as? [LTDictStrObj]
				}
			} else if let array_json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as? Array<LTDictStrObj> where error == nil {
				array = array_json
			}
			if let array = array {
				var array_obj: Array<T> = []
				for a_dict in array { 
					var dict = a_dict
					if let subpaths = self.subpaths {
						for subpath in subpaths {
							dict = dict[subpath] as! LTDictStrObj	//	TODO: subpath checking
						}
					}
					let obj = cls(dict: dict)
					array_obj.append(obj)
				}
				func_array(array_obj, error)
			} else {
				func_array([], error)
			}
		}
		if let func_dict = self.func_dict {
			//let dict = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &error) as LTDictStrObj
			if let dict = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as? LTDictStrObj {
				func_dict(dict, error)
			}
		}
	}

	func form_append(body: NSMutableData, key: String, value: String) {
		let boundary = form_boundary
		body.append_string("--\(boundary)\r\n")
		body.append_string("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
		body.append_string("\(value)\r\n")
	}
	func form_append_dict(body: NSMutableData, param: LTDictStrObj, prefix: String = "") {
		for (key, value) in param {
			var key_nested = key
			if prefix != "" {
				key_nested = prefix + "[" + key + "]"
			}
			if let array = value as? Array<AnyObject> {
				for item in array {
					form_append(body, key:key_nested + "[]", value:item.description)
				}
			} else if let dict = value as? LTDictStrObj {
				form_append_dict(body, param:dict, prefix:key_nested)
			//} else if value is Int || value is Float || value is Double {
			//	form_append(body, key:key_nested, value:value)
			} else {
				form_append(body, key:key_nested, value:value.description)
			}
			//LF.log(key, value.description)
		}
	}
	func form_body(parameters: [String: AnyObject]?, array_data: [NSData]?) -> NSData {
		let boundary = form_boundary
		let body = NSMutableData()

		//body.append_string("\r\ntag_ids[]=134&tag_ids[]=4\r\n")
		if let param = parameters {
			form_append_dict(body, param:param)
		}
		LF.log("body", body.to_string())

		if let array = array_data {
			var index = 0
			for data in array {
				let filePathKey = form_keys[index]
				let filename = "image" + String(index) + ".jpg"
				let mimetype = "image/jpeg"

				body.append_string("\r\n--\(boundary)\r\n")
				body.append_string("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(filename)\"\r\n")
				body.append_string("Content-Type: \(mimetype)\r\n\r\n")
				body.appendData(data)
				body.append_string("\r\n")
				index++
			}
		}

		body.append_string("--\(boundary)--\r\n")
		LF.log("body", body.to_string())
		return body
	}
}

class LRestConnectionDelegate: NSObject {

	var func_done: ((NSURLResponse?, NSData?, NSError!) -> Void)?   //  TODO: make response/data non-nullable
	var credential: NSURLCredential?
	var response: NSURLResponse?
	var data: NSMutableData = NSMutableData()

	func connection(connection: NSURLConnection, willSendRequestForAuthenticationChallenge challenge: NSURLAuthenticationChallenge) {
		if challenge.previousFailureCount > 0 {
			LF.log("challenge cancelled")
			challenge.sender.cancelAuthenticationChallenge(challenge)
		} else if let credential = credential {
			LF.log("challenge added")
			challenge.sender.useCredential(credential, forAuthenticationChallenge:challenge)
		} else {
			LF.log("REST connection will challenge", connection)
		}
	}
	func connection(connection: NSURLConnection, didReceiveResponse a_response: NSURLResponse) {
		//LF.log("CONNECTION response", response)
		response = a_response
	}
	func connection(connection: NSURLConnection, didReceiveData data_received: NSData) {
		//LF.log("CONNECTION data", data.length)
		data.appendData(data_received)
	}
	func connectionDidFinishLoading(connection: NSURLConnection) {
		//LF.log("CONNECTION finished", connection)
		//LF.log("CONNECTION finished", data.to_string())
		if func_done != nil {
			func_done!(response, data, nil)
		}
	}
	func connection(connection: NSURLConnection, didFailWithError error: NSError) {
		//LF.log("CONNECTION failed", error)
		if let func_done = func_done {
			func_done(response, data, error)
		}
	}
	deinit {
		//LF.log("DELEGATE deinit", self)
	}
}

//	model

class LFModel: NSObject {
  
	//	public & reserved
    var id: Int = 0
	var raw: LTDictStrObj?

	struct prototype {
		static var indent: Int = 0
	}

	//	override this function to disable this log. TODO: find a better way.
	func log_description_not_found(value: AnyObject) {
		LF.log("WARNING name 'description' is a reserved word", value)
	}
    required init(dict: Dictionary<String, AnyObject>?) {
        super.init()
		raw = dict
		if dict != nil {
			for (key, value) in dict! {
				//	LF.log(key, value)
				if key == "description" {
					log_description_not_found(value)
				} else if value is NSNull {
					//LF.log("WARNING null value", key)
				} else {
					//	TODO: not working for Int? and Int! in 6.0 GM
					if respondsToSelector(NSSelectorFromString(key)) && key != "keys" {
						//LF.log(key, value)
						setValue(value, forKey:key)
					} else {
    					LF.log("WARNING model ignored", key)
    					LF.log("\tdata", dict)
    					LF.log("\tmodel", self)
    					LF.log("WARNING model ignored end of", key)
					}
					//else { LF.log("no selector", key) }
				}
			}
		} else {
			//LF.log("LFModel empty dict")
		}
    }

	convenience init(filename: String) {
		let dict = NSDictionary(contentsOfFile: filename)
		//LF.log(filename, dict)
		self.init(dict: dict as? LTDictStrObj)
	}
	func save(filename: String, atomically: Bool = true) {
		(dictionary as NSDictionary).writeToFile(filename, atomically: atomically)
	}
	func reload(key: String, type: String) {
		for (a_key, value) in dictionary {
			if let dict_parameter = value as? Dictionary<String, AnyObject> {
				if a_key == key {
					let a_class = NSClassFromString(type) as! LFModel.Type
					let obj = a_class(dict: dict_parameter)
					setValue(obj, forKey:key)
				}
			} else if let array_parameter = value as? Array<AnyObject> {
				if a_key == key {
					var array_new: Array<AnyObject> = []
					for obj in array_parameter {
						if let dict_parameter = obj as? Dictionary<String, AnyObject> {
							//LF.log(key, obj: dict_parameter)
							let a_class = NSClassFromString(type) as! LFModel.Type
							let obj_new = a_class(dict: dict_parameter)
							//LF.log(key, obj: obj_new)
							array_new.append(obj_new)
						}
					}
					setValue(array_new, forKey:key)
				}
			}
		}
	}

	override func valueForUndefinedKey(key: String) -> AnyObject? {
		return nil
	}
    func dictionary(keys: [String]) -> Dictionary<String, AnyObject> {
        var dict: Dictionary<String, AnyObject> = [:]
        for key in keys {
            if let value: AnyObject = valueForKeyPath(key) {
				if let v = value as? LFModel {
					dict[key] = v.dictionary
				} else {
					dict[key] = value
				}
            }
        }
        return dict
    }
	//	TODO: refactor me - should be method instead of property
	var keys: [String] {
        var array = [String]()
        var count: CUnsignedInt = 0
		let properties: UnsafeMutablePointer<objc_property_t> = class_copyPropertyList(object_getClass(self), &count)
   
		var c: AnyClass! = object_getClass(self)
		loop: while c != nil {
			//LF.log("---- class", NSStringFromClass(c))
			var ct: CUnsignedInt = 0
			let prop: UnsafeMutablePointer<objc_property_t> = class_copyPropertyList(c, &ct)
			for var i = 0; i < Int(ct); i++ {
                if let key = NSString(CString: property_getName(prop[i]), encoding: NSUTF8StringEncoding) {
    				if key == "dictionary" {
    					//LF.log("WARNING model: this condition is not ideal")
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
				break
			}
			/*
			if NSStringFromClass(c).contains("LFModel") {
				break
			}
			*/
			c = class_getSuperclass(c)
		}

        for var i = 0; i < Int(count); i++ {
            if let key = NSString(CString: property_getName(properties[i]), encoding: NSUTF8StringEncoding) as? String {
				//LF.log(key, valueForKey(key))
				if let value: AnyObject? = valueForKey(key) {
					array.append(key)
				}
			}
        }
        return array
	}
    //  Nesting is supported. You can also use dictionary(keys) to make dictionary from selected keys.
    var dictionary: Dictionary<String, AnyObject> {
        var dict: Dictionary<String, AnyObject> = [:]
        var count: CUnsignedInt = 0
		let properties: UnsafeMutablePointer<objc_property_t> = class_copyPropertyList(object_getClass(self), &count)
   
		var c: AnyClass! = object_getClass(self)
		loop: while c != nil {
			//	LF.log("---- class", NSStringFromClass(c))
			var ct: CUnsignedInt = 0
			let prop: UnsafeMutablePointer<objc_property_t> = class_copyPropertyList(c, &ct)
			for var i = 0; i < Int(ct); i++ {
                if let key = NSString(CString: property_getName(prop[i]), encoding: NSUTF8StringEncoding) {
    				if key == "dictionary" {
    					//LF.log("WARNING model: this condition is not ideal")
    					break loop
    				}
    				if let value: AnyObject? = valueForKey(key as String) where key != "raw" && key != "keys" {
						dict[key as String] = value
    				}
                }
			}
			//	TODO: apple's bug
			if NSStringFromClass(c) == "NSObject" {
				break
			}
			c = class_getSuperclass(c)
		}

        for var i = 0; i < Int(count); i++ {
            if let key = NSString(CString: property_getName(properties[i]), encoding: NSUTF8StringEncoding) as? String {
				if let value: AnyObject? = valueForKey(key) {
					if let v = value as? LFModel {
						dict[key] = v.dictionary
					} else if let a = value as? [LFModel] {
						var array = [AnyObject]()
						for v in a {
							array.append(v.dictionary)
						}
						dict[key] = array
					} else {
						dict[key] = value
					}
				}
			}
        }
        return dict
    }
   
    override var description: String {
        var s = NSStringFromClass(self.dynamicType)
        s = NSString(format: "%@ (%p): [\r", s, self) as String
		LFModel.prototype.indent++
        for (key, value) in dictionary {
			if key == "raw" {
				continue
			}
			s = append_indent(s)
			if let array = value as? Array<AnyObject> {
				s = s.stringByAppendingFormat("%@: [\r", key)
				LFModel.prototype.indent++
				for obj in array {
					s = append_indent(s)
					s = s.stringByAppendingFormat("%@\r", obj.description)
				}
				LFModel.prototype.indent--
				s = append_indent(s)
				s = s.stringByAppendingString("]\r")
			}
			else if value is Int || value is Float {
				s = s.stringByAppendingFormat("%@: %@\r", key, value.description)
			} else {
				s = s.stringByAppendingFormat("%@: '%@'\r", key, value.description)
			}
        }
		LFModel.prototype.indent--
		s = append_indent(s)
        s = s.stringByAppendingString("]")
        return s
    }

	func append_indent(str: String) -> String {
		var s = str
		for var i = 0; i < LFModel.prototype.indent; i++ {
			//s = s.stringByAppendingString("\t")
			s = s.stringByAppendingString("    ")
		}
		return s
	}
}

class LFAutosaveModel: LFModel {
	//	autosave only makes sense when a back-end service is enabled e.g. Parse, see LFProfile

	var lf_version = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String

	static let autosave_prefix = "Autosave_"		//	TODO
	func autosave_filename() -> String {
        var filename = NSStringFromClass(self.dynamicType)
		filename = filename.stringByReplacingOccurrencesOfString(".", withString: "_", options:nil, range: nil)
		filename = LFAutosaveModel.autosave_prefix + filename + ".xml"
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
        var filename = NSStringFromClass(self.dynamicType)
		filename = filename.stringByReplacingOccurrencesOfString(".", withString: "_", options:nil, range: nil)
		filename = LFAutosaveModel.autosave_prefix + filename + ".xml"
		filename = filename.filename_doc()

		self.init(filename: filename)
		if publish {
			autosave_publish()
		} else {
			autosave_reload()
		}
	}
	func autosave_publish() {
		LF.log("TODO save", "override me")
	}
	func autosave_reload() {
		LF.log("TODO load", "override me")
	}
}

/*
class LRestObject: LFModel {
	var items: [LRestObject] = []	//	impossible to make it dynamic?
	let client = LRestClient<LFModel>()
}
*/

protocol LTableClient {
	func reload()
	func load_more()
	//func reload_table()
	//var func_reload: ([LFModel] -> Void)? { get set }
	//var func_error: (NSError -> Void)? { get set }
	var func_done: (Void -> Void)? { get set }		//	rename me
	var last_loaded: Int { get set }
	var pagination_index: Int { get set }
}

class LArrayClient<T: LFModel>: LRestClient<T>, LTableClient {
	var items = Array<T>()
	var func_reload: ([T] -> Void)?
	var func_error: (NSError -> Void)?
	var func_done: (Void -> Void)?
	var is_loaded = false
	var is_loading = false

	var last_loaded = 0
	var pagination_method = LRest.pagination.Method.None
	var pagination_key: String!
	var pagination_index = 0

	override init(api url: String, parameters param: LTDictStrObj? = nil) {
		super.init(api:url, parameters:param)
		show_error = true
	}
	func reload() {
		pagination_index = 0
		parameters?.removeValueForKey(pagination_key)
		items.removeAll()
		load_more()
	}
	func load_more() {
		if is_loading {
			return
		}
		if pagination_method == .LastID {
			if pagination_index != 0 {
				if let last = items.last {
					LF.log("last", last.id)
					if parameters != nil {
						parameters![pagination_key] = last.id
					} else {
						parameters = [pagination_key: last.id]
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
					for var i = 0; i < self.last_loaded; i++ {
						self.items.removeLast()
					}
					//LF.log("last items removed", self.last_loaded)
				}

				if objs.count > 0 {
					self.pagination_index++
				}
				self.last_loaded = objs.count
				self.items += objs
				if let f = self.func_reload { f(self.items) }
			} else if let f = self.func_error {
				f(error!)
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

class LFRestTableController: LFTableController {
	var client: LTableClient!
	var reload_table = LRest.ui.Reload.First
	var refresh_reload: UIRefreshControl?
	var refresh_more: UIRefreshControl?
	var pull_down = LRest.ui.Load.None
	var pull_up = LRest.ui.Load.None

	override func awakeFromNib() {
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
	override func viewDidLoad() {
		super.viewDidLoad()
		reload_refresh()
		if reload_table != .None {
			client_reload()
		}
	}
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		if reload_table == .Always {
			client_reload()
		}
	}

	func reload_refresh() {
		//	TODO: refactor
		if refresh_reload != nil {
			refresh_reload!.removeFromSuperview()
			refresh_reload = nil
		}
		if refresh_more != nil {
			table.perform("bottomRefreshControl", value:nil)
			refresh_more = nil
		}
		if pull_down == .Reload {
			refresh_reload = UIRefreshControl()
			refresh_reload!.perform("triggerVerticalOffset", value:60)
			refresh_reload!.addTarget(self, action: "client_reload", forControlEvents: .ValueChanged)
			table.addSubview(refresh_reload!)
		} else if pull_down == .More {
			refresh_reload = UIRefreshControl()
			refresh_reload!.perform("triggerVerticalOffset", value:60)
			refresh_reload!.addTarget(self, action: "client_more", forControlEvents: .ValueChanged)
			table.addSubview(refresh_reload!)
		}
		if pull_up == .More && table.respondsToSelector(Selector("bottomRefreshControl")) {
			refresh_more = UIRefreshControl()
			refresh_more!.perform("triggerVerticalOffset", value:60)
			refresh_more!.addTarget(self, action:"client_more", forControlEvents:.ValueChanged)
			table.perform("bottomRefreshControl", value:refresh_more!)
		}
		client.func_done = {
			self.refresh_end()
			if self.client.last_loaded == 0 && self.client.pagination_index != 0 {
				self.show_no_more_items()
			}
		}
	}
	func refresh_end() {
		if let refresh = refresh_reload where self.pull_down != .None {
			refresh.endRefreshing()
		}
		if let refresh = refresh_more where self.pull_up != .None {
			refresh.endRefreshing()
		}
	}
	func client_reload() {
		client.reload()
	}
	func client_more() {
		client.load_more()
	}
	func clear() {
		source.counts = [0]
		source.table.reloadData()
	}
	func show_no_more_items() {
		//	override me
	}
}
