extension MBProgressHUD {
	class func show(title: String, view: UIView, duration: Float? = nil) -> MBProgressHUD {
		let hud = MBProgressHUD.showHUDAddedTo(view, animated: true) 
		hud.detailsLabelFont = UIFont.systemFontOfSize(18)
		hud.detailsLabelText = title
		if duration != nil {
			hud.mode = MBProgressHUDMode.Text
			hud.minShowTime = duration!
			hud.graceTime = duration!
			MBProgressHUD.hideAllHUDsForView(view, animated:true)
		}
        return hud
	}
}

extension LF {
	static func track_parameters(parameters: LTDictStrStr? = nil, error: NSError? = nil) -> LTDictStrStr? {
		var dict = LTDictStrStr()
		if let param = parameters {
			dict = param
		}
		if let error = error {
			dict["error-code"] = String(error.code)
			dict["error-description"] = String(error.localizedDescription)
		}
		if dict.count == 0 {
			return nil
		}
		return dict
	}
	static func track(event: String, parameters: LTDictStrStr? = nil, begin: Bool = false, error: NSError? = nil) {
		if let dict = track_parameters(parameters, error: error) {
			PFAnalytics.track(event, dimensions: dict, error: error)
			Flurry.logEvent(event, withParameters: dict, timed: begin)
		} else {
			PFAnalytics.track(event, error: error)
			Flurry.logEvent(event, timed: begin)
		}
		LF.log("TRACKING begin", event)
	}
	static func track_end(event: String, parameters: LTDictStrStr? = nil, timed: Bool = false, error: NSError? = nil) {
		let dict = track_parameters(parameters, error: error)
		Flurry.endTimedEvent(event, withParameters: dict)
		LF.log("TRACKING end", event)
	}
}
