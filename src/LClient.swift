import Foundation

//	client
struct LRest {
	static let domain = "LRestKit"
	struct error {
		static let invalid_parameter = 10000001
		static let empty_response = 10000002
	}
	struct content {
		static let json = "application/json"
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
	struct cache {
		enum Policy {
			case Disabled
			case CacheThenNetwork
		}
	}
}

class LRestClient<T: LFModel> {
	var path: String?										//	to support results like ["user": [], "succuss" = 1]
	var text: String?
	var show_error = false
	var content_type = LRest.content.json
	var method = LRest.method.get
	var root: String!
	var api: String!
	var parameters: LTDictStrObj?
	var func_model: ((T?, NSError?) -> Void)?				//	parse to model
	var func_array: ((Array<T>?, NSError?) -> Void)?		//	parse to array
	var func_dict: ((LTDictStrObj?, NSError?) -> Void)?		//	raw dictionary
	var response: NSHTTPURLResponse?
	var credential: NSURLCredential?
	var cache_policy = LRest.cache.Policy.Disabled

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
	func reload_api() {
		if method.rawValue == "GET" && parameters != nil {
			api = api + "?"

			//	TODO: encoding
			for (key, value) in parameters! {
				if value is String {
					api = api + key + "=" + String(value as String) + "&"
				} else if value is Int {
					api = api + key + "=" + String(value as Int) + "&"
				} else {
					LF.log("WARNING unknown parameter type", value)
				}
			}
			api = api.sub_range(0, -1)
			//LF.log("url", api)
		}
	}
	func init_request() -> NSMutableURLRequest? {
		var url = NSURL(string: root + api)!
		var request = NSMutableURLRequest(URL: url)
		request.HTTPMethod = method.rawValue
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
		return request
	}
	var connection: NSURLConnection?
	func execute() {
		reload_api()
		if self.cache_policy == .CacheThenNetwork {
			let filename = self.get_filename()
			if let data = NSData(contentsOfFile:filename) {
				LF.log("CACHE loaded")
				//LF.dispatch() { self.execute_data(data) }
			}
		}
		if let request = init_request() {

			var error_ret: NSError?
			if text != nil {
				text_show()
			}
			//	TODO: change data and error to optional
			var func_done = {
				(response: NSURLResponse?, data: NSData?, error: NSError!) -> Void in

				var error_ret: NSError? = error
				if self.text != nil {
					self.text_hide()
				}

				var resp = response as NSHTTPURLResponse?
				self.response = resp
				if error != nil {
					//	LF.log("CLIENT error", error)
				} else if resp == nil {
					//	LF.log("url empty response", data)
					error_ret = NSError(domain: LRest.domain, code: LRest.error.empty_response, userInfo:[NSLocalizedDescriptionKey: "LRestKit: empty response"])
				} else if resp!.statusCode < 200 || resp!.statusCode >= 300 {
					//	LF.log("url failed", response)
					let code = resp!.statusCode
					error_ret = NSError(domain: LRest.domain, code: code, userInfo:[NSLocalizedDescriptionKey: NSHTTPURLResponse.localizedStringForStatusCode(code)])
				} else {
					if self.cache_policy != .Disabled {
						let filename = self.get_filename()
						data?.writeToFile(filename, atomically:true)
						LF.log("CACHE saved")
					}
					self.execute_data(data!)
					/*
					error_ret = nil
					let s = NSString(data: data!, encoding: NSUTF8StringEncoding)
					let cls = T.self
					if self.func_model != nil {
						var dict = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: &error_ret) as LTDictStrObj?
						//	TODO: support multi-layer path
						if let path = self.path {
							if var dict_tmp = dict?[path] as? LTDictStrObj {
								dict = dict_tmp
							}
						}
						if error_ret == nil {
							let obj = cls(dict: dict)
							self.func_model!(obj, error_ret)
						}
					}
					if self.func_array != nil {
						let array = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: &error_ret) as Array<LTDictStrObj>
						if error_ret == nil {
							var array_obj: Array<T> = []
							for dict in array { 
								let obj = cls(dict: dict)
								array_obj.append(obj)
							}
							self.func_array!(array_obj, error_ret)
						}
					}
					if self.func_dict != nil {
						//let dict = NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments, error: &error_ret) as LTDictStrObj
						let dict = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: &error_ret) as LTDictStrObj
						if error_ret == nil {
							self.func_dict!(dict, error_ret)
						}
					}
					*/
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
			let delegate = LRestConnectionDelegate()
			delegate.credential = credential
			delegate.func_done = func_done
			connection = NSURLConnection(request:request, delegate:delegate, startImmediately:true)
			//LF.log("CONNECTION started", connection!)
		} else {
			LF.log("WARNING LClient", "empty request")
		}
	}
	func cancel() {
		if let connection = connection {
			connection.cancel()
		}
	}
    deinit {
        //LF.log("CLIENT deinit", self)
    }

	func get_filename() -> String {
		var param_hash = self.parameters?.description.hash
		if param_hash == nil {
			param_hash = 0
		}
		let filename = String(format:"%@-%@-%i.xml", 
			self.root.to_filename(), self.api.to_filename(), param_hash!)
		return filename.to_filename(directory: .CachesDirectory)
	}
	func execute_data(data: NSData!) {

		var error: NSError?
		let s = NSString(data: data, encoding: NSUTF8StringEncoding)
		let cls = T.self
		if self.func_model != nil {
			var dict = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as LTDictStrObj?
			//	TODO: support multi-layer path
			if let path = self.path {
				if var dict_tmp = dict?[path] as? LTDictStrObj {
					dict = dict_tmp
				}
			}
			if error == nil {
				let obj = cls(dict: dict)
				self.func_model!(obj, error)
			}
		}
		if self.func_array != nil {
			let array = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as Array<LTDictStrObj>
			if error == nil {
				var array_obj: Array<T> = []
				for dict in array { 
					let obj = cls(dict: dict)
					array_obj.append(obj)
				}
				self.func_array!(array_obj, error)
			}
		}
		if self.func_dict != nil {
			//let dict = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &error) as LTDictStrObj
			let dict = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as LTDictStrObj
			if error == nil {
				self.func_dict!(dict, error)
			}
		}
	}
}

class LRestConnectionDelegate: NSObject {

	var func_done: ((NSURLResponse?, NSData?, NSError!) -> Void)?
	var credential: NSURLCredential?
	var response: NSURLResponse?
	var data: NSMutableData = NSMutableData()

	func connection(connection: NSURLConnection, willSendRequestForAuthenticationChallenge challenge: NSURLAuthenticationChallenge) {
		if challenge.previousFailureCount > 0 {
			challenge.sender.cancelAuthenticationChallenge(challenge)
		} else if let credential = credential {
			//LF.log("challenge added")
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
		if func_done != nil {
			func_done!(response, data, nil)
		}
	}
	func connection(connection: NSURLConnection, didFailWithError error: NSError) {
		//LF.log("CONNECTION failed", error)
		if let func_done = func_done {
			func_done(response, nil, error)
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
					if respondsToSelector(NSSelectorFromString(key)) {
						setValue(value, forKey:key)
					} else {
    					LF.log("WARNING model ignored '" + key + "' in", self)
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
					let a_class = NSClassFromString(type) as LFModel.Type
					let obj = a_class(dict: dict_parameter)
					setValue(obj, forKey:key)
				}
			} else if let array_parameter = value as? Array<AnyObject> {
				if a_key == key {
					var array_new: Array<AnyObject> = []
					for obj in array_parameter {
						if let dict_parameter = obj as? Dictionary<String, AnyObject> {
							//LF.log(key, obj: dict_parameter)
							let a_class = NSClassFromString(type) as LFModel.Type
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
                if let key = NSString(CString: property_getName(prop[i]), encoding: NSUTF8StringEncoding)? {
    				if key == "dictionary" {
    					//LF.log("WARNING model: this condition is not ideal")
    					break loop
    				}
    				if let value: AnyObject? = valueForKey(key) {
    					dict[key] = value
    				}
                }
			}
			//	TODO: apple's bug
			if NSStringFromClass(c) == "NSObject" {
				break
			}
			c = class_getSuperclass(c)
		}

		/*
        for var i = 0; i < Int(count); i++ {
            let key: NSString = NSString(CString: property_getName(properties[i]), encoding: NSUTF8StringEncoding)
            if let value: AnyObject? = valueForKey(key) {
                dict[key] = value
            }
        }
		*/
        return dict
    }
   
    override var description: String {
        var s = NSStringFromClass(self.dynamicType)
        s = NSString(format: "%@ (%p): [\r", s, self)
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

/*
//	parse: does it really make sense?
extension LFModel {
	func parse_upload() -> PFObject {
        var s = NSStringFromClass(self.dynamicType)
		s = s.stringByReplacingOccurrencesOfString(".", withString: "_", options:nil, range: nil)
		var pf = PFObject(className: s)
		LF.log("---- class", s)
		LF.log("---- class", self.id)
        for (key, value) in dictionary {
			if let array = value as? Array<AnyObject> {
				s = s.stringByAppendingFormat("%@: [\r", key)
				LF.log("array key", key)
				var array_pf: Array<AnyObject> = []
				for obj in array {
					LF.log("array value", obj)
					if obj is LFModel {
						let pf2 = obj.parse_upload()
						array_pf.append(pf2)
					} else {
						array_pf.append(parse_compatible(obj))
					}
				}
				pf.setObject(array_pf, forKey:key)
			/*
			} else if value is Int || value is Float {
				LF.log("number key", key)
				LF.log("number value", value)
				pf.setObject(value, forKey:key)
			*/
			} else {
				LF.log("obj key", key)
				LF.log("obj value", value)
				if value is LFModel {
					let pf2 = value.parse_upload()
					pf.setObject(pf2, forKey:key)
				} else {
					pf.setObject(parse_compatible(value), forKey:key)
				}
			}
        }
		var error: NSError?
		let result = pf.save(&error)
		LF.log("----", error)
		return pf
	}
	func parse_compatible(obj: AnyObject) -> AnyObject {
		if obj is UIColor {
			return "TODO:UIColor"
		}
		return obj
	}
}
*/

