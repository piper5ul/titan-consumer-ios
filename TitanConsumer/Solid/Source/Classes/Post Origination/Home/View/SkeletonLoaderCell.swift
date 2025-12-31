//
//  SkeletonLoaderCell.swift
//  Solid
//
//  Created by Solid iOS Team on 22/02/21.
//

import Foundation
import UIKit

class SkeletonLoaderCell: UITableViewCell {
   @IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        self.titleLabel.font = UIFont.sfProDisplayMedium(fontSize: 16)
        self.titleLabel.textColor = UIColor.lightGray
        self.descriptionLabel.font = UIFont.sfProDisplayRegular(fontSize: 12.0)
        self.descriptionLabel.textColor = UIColor.lightGray
		self.contentView.layer.cornerRadius = Constants.cornerRadiusThroughApp
    }
}
