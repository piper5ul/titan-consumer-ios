//
//  BaseImageView.swift
//  Solid
//
//  Created by Solid iOS Team on 03/11/20.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit

class BaseImageView: UIImageView {
    @IBInspectable var customTintColor: UIColor = UIColor.primaryColor {
        didSet {
            updateImageColor()
        }
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
		self.layer.cornerRadius = cornerRadius
        updateImageColor()
    }

    func updateImageColor() {
        if let aImage = self.image {
            let imgTemplate = aImage.withRenderingMode(.alwaysTemplate)
            self.image = imgTemplate
            self.tintColor = customTintColor
        }
    }

    override init(image: UIImage?) {
        super.init(image: image)

        if let aImage = image {
            self.setImage(image: aImage)
        }
    }

    func setImage(image: UIImage) {
        self.image =  image
    }

    func makeIconImageView(for imageName: String) {
        self.layer.cornerRadius = self.frame.size.height/2
        self.backgroundColor = UIColor.secondaryColor

        if let aImage = UIImage(named: imageName) {
//            let imgTemplate = aImage.withRenderingMode(.alwaysTemplate)
            self.image = aImage// imgTemplate
//            self.tintColor = UIColor.white
        }
    }
}
