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
				lf_enableBorder()
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
