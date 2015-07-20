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

class LParseClient<T: LFModel>: PFQuery {
	//init(class_name: String) { }
}

class LFConfigModel: LFModel {
	//var object_id: String?
	//var created_at: NSDate?
	//var updated_at: NSDate?

	func config_filename() -> String {
		return ("AppConfig_" + parse_class() + ".xml").filename_doc()
	}
	//	publish
	//		true: publish config (debug build only)
	//		false: download config
	//	reload_immediately
	//		true: overwrite config immediately after it's downloaded (default)
	//		false: config will be available from next app launch (not implemented)
	convenience init(publish: Bool, reload_immediately: Bool = true) {
		//	TODO: how to call config_filename() instead? is double-init a must?
        var filename = NSStringFromClass(self.dynamicType)
		filename = filename.stringByReplacingOccurrencesOfString(".", withString: "_", options:nil, range: nil)
		filename = "AppConfig_" + filename + ".xml"
		filename = filename.filename_doc()

		self.init(filename: filename)
		//LF.log("CONFIG inited", self)
		if publish {
			LF.log("CONFIG publishing", self)
			let obj = parse_object()
			obj.saveInBackgroundWithBlock() {
				(success, error) -> Void in
				LF.log("CONFIG published, error", error)
			}
		} else {
			reload_config()
		}
	}
	func reload_config() {
		let query = PFQuery(className:parse_class())
		query.getFirstObjectInBackgroundWithBlock() {
			(object, error) -> Void in
			if error == nil {
				//LF.log("CONFIG reloaded", object)
				if let obj = object {
					self.parse_load(obj)
					self.save(self.config_filename())
				}
			} else {
				LF.log("CONFIG reload error", error)
			}
		}
	}
	override func parse_load(object: PFObject) {
		super.parse_load(object)
		//object_id	= object.objectId
		//created_at	= object.createdAt
		//updated_at	= object.updatedAt
		//LF.log("CONFIG loaded", self)
	}
}

extension LFModel {
	func parse_class() -> String {
        var s = NSStringFromClass(self.dynamicType)
		s = s.stringByReplacingOccurrencesOfString(".", withString: "_", options:nil, range: nil)
		return s
	}
	func parse_object() -> PFObject {
		//LF.log("---- class", s)
		//LF.log("---- class", self.id)
		var object = PFObject(className: parse_class())
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
		let dict = dictionary
		for key in object.allKeys() {
			if let key = key as? String {
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
