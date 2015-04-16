import UIKit

//	UIKit + Interface Builder: define various UIView properties in IB


//	TODO: add getters when extension property is added - having problem with associating in swift (key cannot be a string variable)
extension UIView {
	@IBInspectable var font_name: String? {
		get {
			if self is UILabel {
				let label = self as UILabel
				return label.font.fontName
			} else if self is UITextField {
				let field = self as UITextField
				return field.font.fontName
			} else if self is UITextView {
				let text = self as UITextView
				return text.font.fontName
			} else if self is UIButton {
				let button = self as UIButton
				return button.titleLabel!.font.fontName
			}
			return nil
		}
		set (name) {
			if self is UILabel {
				let label = self as UILabel
				label.font = UIFont(name: name!, size: label.font.pointSize)
			} else if self is UITextField {
				let field = self as UITextField
				field.font = UIFont(name: name!, size: field.font.pointSize)
			} else if self is UITextView {
				let text = self as UITextView
				text.font = UIFont(name: name!, size: text.font.pointSize)
			} else if self is UIButton {
				let button = self as UIButton
				button.titleLabel!.font = UIFont(name: name!, size: button.titleLabel!.font.pointSize)
			} else {
				LF.log("WARNING unknown type for font_name in Interface Builder", self)
			}
		}
	}
	@IBInspectable var enable_mask_circle: Bool {
		get {
			LF.log("WARNING no getter for UIView.enable_mask_circle")
			return false
		}
		set (enabled) {
			if Bool(enabled) == true {
				lf_enableBorder(is_circle: true)
			} else {
				layer.cornerRadius = 0
			}
		}
	}
	@IBInspectable var mask_radius: CGFloat {
		get {
			LF.log("WARNING no getter for UIView.mask_radius")
			return 0
		}
		set (f) {
			lf_enableBorder(radius: f)
		}
	}
	@IBInspectable var border_width: CGFloat {
		get {
			LF.log("WARNING no getter for UIView.mask_border")
			return 0
		}
		set (f) {
			lf_enableBorder(width: f)
		}
	}
	@IBInspectable var border_color: UIColor? {
		get {
			LF.log("WARNING no getter for UIView.mask_color")
			return nil
		}
		set (c) {
			lf_enableBorder(color: c)
		}
	}
}

extension UITextField {
	@IBInspectable var padding_left: CGFloat {
		get {
			LF.log("WARNING no getter for UITextField.padding_left")
			return 0
		}
		set (f) {
			layer.sublayerTransform = CATransform3DMakeTranslation(f, 0, 0)
		}
	}
}

extension UIScrollView {
	@IBInspectable var content_width: CGFloat {
		get {
			return content_w
		}
		set (f) {
			content_w = f
		}
	}
	@IBInspectable var content_height: CGFloat {
		get {
			return content_h
		}
		set (f) {
			content_h = f
		}
	}
}

extension UIButton {
	@IBInspectable var title_align_center: Bool {
		get {
			if let label = titleLabel {
				return label.textAlignment == .Center
			}
			return false
		}
		set (f) {
			if let label = titleLabel {
				label.textAlignment = .Center
			}
		}
	}
	@IBInspectable var highlighted_background_color: UIColor {
		get {
			return UIColor.blackColor()		//	TODO
		}
		set (color) {
			//let image = UIImage(CIImage: CIImage(color: CIColor(color: color)))	//why not working?
			let image = UIImage(color: color)
			setBackgroundImage(image, forState: .Highlighted)
		}
	}
	@IBInspectable var selected_background_color: UIColor {
		get {
			return UIColor.blackColor()		//	TODO
		}
		set (color) {
			let image = UIImage(color: color)
			setBackgroundImage(image, forState: .Selected)
		}
	}
	@IBInspectable var disabled_background_color: UIColor {
		get {
			return UIColor.blackColor()		//	TODO
		}
		set (color) {
			let image = UIImage(color: color)
			setBackgroundImage(image, forState: .Disabled)
		}
	}
}

extension UITextView {
	@IBInspectable var align_middle_vertical: Bool {
		get {
			return false	//	TODO
		}
		set (f) {
			self.addObserver(self, forKeyPath:"contentSize", options:.New, context:nil)
		}
	}
	override public func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject:AnyObject], context: UnsafeMutablePointer<Void>) {
		if let textView = object as? UITextView {
			var y: CGFloat = (textView.bounds.size.height - textView.contentSize.height * textView.zoomScale)/2.0;
			if y < 0 {
				y = 0
			}
			textView.content_y = -y
		}
	}
}

class LFAlertSegue: UIStoryboardSegue {
    override func perform() {
        let source = sourceViewController as UIViewController
        if let navigation = source.navigationController {
			let alert = UIAlertController(title: "Message", message: identifier, preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {
				(action: UIAlertAction!) -> Void in
			}))
			navigation.presentViewController(alert, animated: true, completion: nil)
            //navigation.pushViewController(destinationViewController as UIViewController, animated: false)
        }
    }
}

class LFActionSheetSegue: UIStoryboardSegue {
    override func perform() {
        let source = sourceViewController as UIViewController
        if let navigation = source.navigationController {
			let alert = UIAlertController(title: "Message", message: identifier, preferredStyle: .ActionSheet)
			alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {
				(action: UIAlertAction!) -> Void in
			}))
			navigation.presentViewController(alert, animated: true, completion: nil)
            //navigation.pushViewController(destinationViewController as UIViewController, animated: false)
        }
    }
}
