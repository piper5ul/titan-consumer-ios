//
//  SkeletonCollectionCell.swift
//  Solid
//
//  Created by Solid iOS Team on 22/02/21.
//

import Foundation
import UIKit

class SkeletonCollectionCell: UICollectionViewCell {
   @IBOutlet weak var titleLabel: UILabel!
   @IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var imgSkeleton: UIImageView!

    override func awakeFromNib() {
		self.imgSkeleton.layer.cornerRadius = Constants.cornerRadiusThroughApp
		self.contentView.layer.cornerRadius = Constants.cornerRadiusThroughApp
    }
}
