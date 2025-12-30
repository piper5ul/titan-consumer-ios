//
//  UIImage+Utility.swift
//  Solid
//
//  Created by Solid iOS Team on 24/05/21.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit
import SDWebImage
import SDWebImageSVGCoder

extension UIImageView {
	func getImage(url: String, placeholderImage: UIImage?, success:@escaping (_ _result: Any? ) -> Void, failer:@escaping (_ _result: Any? ) -> Void) {
		self.sd_imageIndicator = SDWebImageActivityIndicator.gray
		self.sd_setImage(with: URL(string: url), placeholderImage: placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { image, error, _, _ in
			// your rest code
			if error == nil {
				self.image = image
				success(true)
			} else {
				failer(false)
			}
		})
	}

	func loadSVGImage(url: String, placeholderImage: UIImage?, success:@escaping (_ _result: Any? ) -> Void, failer:@escaping (_ _result: Any? ) -> Void) {
		let svgCoder = SDImageSVGCoder.shared
		SDImageCodersManager.shared.addCoder(svgCoder)

		self.sd_setImage(with: URL(string: url), placeholderImage: placeholderImage, options: SDWebImageOptions.refreshCached, completed: { image, error, _, _ in
            // your rest code
            if error == nil {
				if let urlimage = image {
					self.image = urlimage
				}
                success(true)
            } else {
                failer(false)
            }
        })

		self.contentMode = .scaleAspectFit
	}
}
