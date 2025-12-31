//
//  WSLabel.swift
//  Solid
//
//  Created by Solid iOS Team on 7/2/19.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit

extension UILabel {

    func setupLineSpacing(lineSpacing spacing: CGFloat) {

        if let labelString = self.text, !labelString.isEmpty {
            self.attributedText = labelString.getAttributedString(forLineSpacing: spacing)
        }
    }
	
	var letterSpace: CGFloat {
		get {
			if let currentLetterSpace = attributedText?.attribute(NSAttributedString.Key.kern, at: 0, effectiveRange: .none) as? CGFloat {
				return currentLetterSpace
			} else {
				return 0
			}
		}
		set {
			let attributedString: NSMutableAttributedString!
			if let currentAttrString = attributedText {
				attributedString = NSMutableAttributedString(attributedString: currentAttrString)
			} else {
				attributedString = NSMutableAttributedString(string: text ?? "")
				text = nil
			}
			
			attributedString.addAttribute(NSAttributedString.Key.kern,
										  value: newValue,
										  range: NSRange(location: 0, length: attributedString.length))
			
			attributedText = attributedString
		}
	}
}
