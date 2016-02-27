extension PFAnalytics {
	class func track(event: String, dimensions: LTDictStrStr = [:], error: NSError? = nil) {
		PFAnalytics.trackEventInBackground(event, dimensions:dimensions, block:nil)
	}
}

extension PFObject {
    //  TODO: find a proper synonym to replace "def" (default)
    func string(key: String, def: String = "") -> String {
        if let s = self[key] as? String {
            return s
        }
        return def
    }
    func integer(key: String, offset: Int? = nil, def: Int = 0) -> Int {
        var ret = def
        if let i = self[key] as? Int {
            ret = i
        }
        if let offset = offset {
            ret += offset
            self[key] = ret
        }
        return ret
    }
}

class LFProfile: LFAutosaveModel {
	//	TODO: currently the size of a profile is limited to 128K
	
	override func autosave_publish() {
		LF.log("PROFILE publishing", self)
		let obj = parse_object()
		obj.saveInBackgroundWithBlock() {
			(success, error) -> Void in
			LF.log("PROFILE published, error", error)
		}
	}
	override func autosave_reload() {
		let query = PFQuery(className:parse_class())
		query.orderByDescending("createdAt")
		query.getFirstObjectInBackgroundWithBlock() {
			(object, error) -> Void in
			if error == nil {
				//LF.log("PROFILE reloaded", object)
				if let obj = object {
					self.parse_load(obj)
					self.save(self.autosave_filename())
				}
			} else {
				LF.log("PROFILE reload failed", self)
				LF.log("PROFILE reload error", error)
			}
		}
	}
}

class LFParseLocalizable: LFLocalizable {
	
	convenience init(filename: String) {
		let dict = NSDictionary(contentsOfFile: filename)
		//LF.log(filename, dict)
		self.init(dict: nil)
		//self.init(dict: dict as? LTDictStrObj)
		if let dict = dict as? [String: [AnyObject]] {
			for key in Array(dict.keys) {
				//LF.log(key, dict[key])
				if var item = valueForKey(key) as? Item, let array = dict[key] as? [String] {
					if item.array.count >= array.count {
						item.array.removeAll()
					}
					for s in array {
						item += s
					}
				}
			}
		}
	}
	override func autosave_publish() {
		//LF.log("LOCALIZABLE publishing", self)
		var count = 0
        for (_, value) in dictionary {
			if let array = value as? [String] {
				count = array.count - 1
				break
			}
        }
		LF.dispatch() {
			var dict = self.dictionary
			dict["lf_language"] = self.lf_language.array
			for i in 0 ... count {
				let object = PFObject(className: self.parse_class())
				for (key, value) in dict {
					if let array = value as? [String] where array.count > i {
						let s = array[i]
						object[key] = s
						//LF.log(key, s)
					}
				}
				object.saveInBackgroundWithBlock() {
					(success, error) -> Void in
					LF.log("PROFILE published, error", error)
				}
				/*
				do {
    				try object.save()
				} catch let e as NSError {
					LF.log("SAVE failed", e)
				}
				*/
				LF.log("LOCALIZABLE publishing", i)
			}
		}
	}
	override func autosave_reload() {
		let query = PFQuery(className:parse_class())
		query.orderByAscending("createdAt")
		query.findObjectsInBackgroundWithBlock() {
			(objects, error) -> Void in
			//LF.log("AUTOSAVE objects", objects)
			//LF.log("AUTOSAVE error", error)
			if let objects = objects where error == nil {
				for object in objects {
					for key in object.allKeys() {
						if key != "keys" {
							//LF.log(key, object[key])
							if var item = self.valueForKey(key) as? Item, let s = object[key] as? String {
								//	TODO: currently a brand new language cannot be added in Parse dashboard
								if item.array.count >= objects.count {
									item.array.removeAll()
								}
								item += s
							}
						}
					}
				}
				self.save(self.autosave_filename())
				//LF.log("LOCALIZABLE reloaded", self)
			} else {
				LF.log("LOCALIZABLE reload failed", self)
				LF.log("LOCALIZABLE reload error", error)
			}
		}
	}
}

extension LFModel {
	func parse_class() -> String {
        var s = NSStringFromClass(self.dynamicType)
		s = s.stringByReplacingOccurrencesOfString(".", withString: "_", options:[], range: nil)
		return s
	}
	func parse_object() -> PFObject {
		//LF.log("---- class", s)
		//LF.log("---- class", self.id)
		let object = PFObject(className: parse_class())
        for (key, value) in dictionary {
			object[key] = value
			/*
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
				object.setObject(array_pf, forKey:key)
			} else if value is Int || value is Float {
				LF.log("number key", key)
				LF.log("number value", value)
				object.setObject(value, forKey:key)
			} else {
				LF.log("obj key", key)
				LF.log("obj value", value)
				if value is LFModel {
					let pf2 = value.parse_upload()
					object.setObject(pf2, forKey:key)
				} else {
					object.setObject(parse_compatible(value), forKey:key)
				}
			}
			*/
        }
		/*
		var error: NSError?
		let result = object.save(&error)
		LF.log("----", error)
		*/
		return object
	}
	func parse_load(object: PFObject) {
		for key in object.allKeys() {
			if key != "keys" {
				//LF.log(key, object[key])
				setValue(object[key], forKey:key)
			}
		}
	}
	func parse_compatible(obj: AnyObject) -> AnyObject {
		if obj is UIColor {
			return "TODO:UIColor"
		}
		return obj
	}
}
