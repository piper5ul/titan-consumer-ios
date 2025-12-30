//
//  BaseButton.swift
//  Solid
//
//  Created by Solid iOS Team on 10/02/21.
//

import Foundation
import UIKit

class BaseButton: UIButton {

    func set(title: String) {
        self.setTitle(title, for: .normal)
        self.setTitle(title, for: .selected)
        self.setTitle(title, for: .highlighted)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialise()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialise()
    }

    func initialise() {
        self.backgroundColor = UIColor.brandColor // UIColor.primaryColor
		let titleFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
        self.titleLabel?.font = titleFont
        self.layer.cornerRadius = Constants.cornerRadiusThroughApp
        updateImageColor()
    }

    func updateImageColor() {
        if let aImage = self.imageView?.image {
            let imgTemplate = aImage.withRenderingMode(.alwaysTemplate)
            self.imageView?.image = imgTemplate
            self.imageView?.tintColor = .primaryColor
        }
    }

    func setCornerRadius(corner: CGFloat) {
        self.layer.cornerRadius = corner
    }

    func makeIconButton(for imageName: String) {
        self.layer.cornerRadius = self.frame.size.height/2
        self.backgroundColor = UIColor.primaryColor
        if let image = UIImage(named: imageName) {
            self.setImage(image, for: .normal)
        }
    }
}
