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
	var form_data: [NSData]?
	var form_keys = ["file", "file1", "file2"]

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
					api = api + key + "=" + String(value as! String) + "&"
				} else if value is Int {
					api = api + key + "=" + String(value as! Int) + "&"
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
		if content_type == LRest.content.form {
			let boundary = generateBoundaryString()
			request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
			request.HTTPBody = createBodyWithParameters(parameters, array_data:form_data, boundary: boundary)
			LF.log("body", request.HTTPBody?.to_string())
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
		return request
	}
	var connection: NSURLConnection?
	func execute() {
		reload_api()
		if self.cache_policy == .CacheThenNetwork {
			let filename = self.get_filename()
			if let data = NSData(contentsOfFile:filename) {
				LF.log("CACHE loaded")
				//LF.dispatch() { }
				self.execute_data(data)
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

				var resp = response as! NSHTTPURLResponse?
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
			var dict = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as! LTDictStrObj?
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
			let array = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as! Array<LTDictStrObj>
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
			let dict = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as! LTDictStrObj
			if error == nil {
				self.func_dict!(dict, error)
			}
		}
	}

	/// Create request
	///
	/// :param: userid   The userid to be passed to web service
	/// :param: password The password to be passed to web service
	/// :param: email    The email address to be passed to web service
	///
	/// :returns:         The NSURLRequest that was created

	/*
	func createRequest (#userid: String, password: String, email: String) -> NSURLRequest {
		let param = [
			"user_id"  : userid,
			"email"    : email,
			"password" : password]  // build your dictionary however appropriate

		let boundary = generateBoundaryString()

		let url = NSURL(string: "https://example.com/imageupload.php")
		let request = NSMutableURLRequest(URL: url)
		request.HTTPMethod = "POST"
		request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

		let path1 = NSBundle.mainBundle().pathForResource("image1", ofType: "png") as String!
		let path2 = NSBundle.mainBundle().pathForResource("image2", ofType: "jpg") as String!
		request.HTTPBody = createBodyWithParameters(param, filePathKey: "file", paths: [path1, path2], boundary: boundary)

		return request
	}
	*/

	/// Create body of the multipart/form-data request
	///
	/// :param: parameters   The optional dictionary containing keys and values to be passed to web service
	/// :param: filePathKey  The optional field name to be used when uploading files. If you supply paths, you must supply filePathKey, too.
	/// :param: paths        The optional array of file paths of the files to be uploaded
	/// :param: boundary     The multipart/form-data boundary
	///
	/// :returns:            The NSData of the body of the request

	//func createBodyWithParameters(parameters: [String: AnyObject]?, filePathKey: String?, paths: [String]?, boundary: String) -> NSData {
	func createBodyWithParameters(parameters: [String: AnyObject]?, array_data: [NSData]?, boundary: String) -> NSData {
		let body = NSMutableData()

		LF.log("xx1", parameters)
		if let param = parameters {
			for (key, value) in param {
				let desc = value.description
				body.append_string("--\(boundary)\r\n")
				body.append_string("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
				body.append_string("\(desc)\r\n")
				LF.log(key, value.description)
			}
		}

		if let array = array_data {
			var index = 0
			for data in array {
				/*
				let filename = path.lastPathComponent
				let data = NSData(contentsOfFile: path)
				let mimetype = mimeTypeForPath(path)
				*/
				//let filePathKey = "file" + String(index)
				let filePathKey = form_keys[index]
				let filename = "image" + String(index) + ".jpg"
				let mimetype = "image/jpeg"

				body.append_string("--\(boundary)\r\n")
				body.append_string("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(filename)\"\r\n")
				body.append_string("Content-Type: \(mimetype)\r\n\r\n")
				body.appendData(data)
				body.append_string("\r\n")
				index++
			}
		}

		body.append_string("--\(boundary)--\r\n")
				LF.log("xx2", body.to_string())
		return body
	}

	/// Create boundary string for multipart/form-data request
	///
	/// :returns:            The boundary string that consists of "Boundary-" followed by a UUID string.

	func generateBoundaryString() -> String {
		//return "Boundary-\(NSUUID().UUID().UUIDString)"
		return "---------------------------14737809831466499882746641449"
	}

	/// Determine mime type on the basis of extension of a file.
	///
	/// This requires MobileCoreServices framework.
	///
	/// :param: path         The path of the file for which we are going to determine the mime type.
	///
	/// :returns:            Returns the mime type if successful. Returns application/octet-stream if unable to determine mime type.

	/*
	func mimeTypeForPath(path: String) -> String {
		let pathExtension = path.pathExtension

		if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
			if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
				return mimetype as NSString
			}
		}
		return "application/octet-stream";
	}
	*/
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
    				if let value: AnyObject? = valueForKey(key as String) {
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

