//
//  UIFont+Utility.swift
//  Solid
//
//  Created by Solid iOS Team on 08/02/21.
//

import UIKit

extension UIFont {

	// MARK: - SF Pro Display
	static func sfProDisplayBold(fontSize size: CGFloat) -> UIFont {
		return UIFont(name: "SFProDisplay-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
	}

	static func sfProDisplayMedium(fontSize size: CGFloat) -> UIFont {
		return UIFont(name: "SFProDisplay-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
	}

	static func sfProDisplayRegular(fontSize size: CGFloat) -> UIFont {
		return UIFont(name: "SFProDisplay-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
	}

	static func sfProDisplayBlack(fontSize size: CGFloat) -> UIFont {
		return UIFont(name: "SFProDisplay-Black", size: size) ?? UIFont.systemFont(ofSize: size)
	}
}
