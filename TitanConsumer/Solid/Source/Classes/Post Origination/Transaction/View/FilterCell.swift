//
//  FilterCell.swift
//  Solid
//
//  Created by Solid iOS Team on 15/03/21.
//

import UIKit

class FilterCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var removeButton: BaseButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.cornerRadius = Constants.cornerRadiusThroughApp
        self.clipsToBounds = true
        self.backgroundColor = .background
        
		let titleFont = Utility.isDeviceIpad() ? Constants.mediumFontSize14: Constants.mediumFontSize12
        titleLabel.font = titleFont
        titleLabel.textColor = UIColor.primaryColor
        removeButton.tintColor = .primaryColor
    }

    public class func size (filter value: String, indexPath: IndexPath) -> CGSize {
        var aSize = value.sizeOfString(usingFont: UIFont.sfProDisplayRegular(fontSize: 16))
        aSize.width += 50 // padding
        aSize.height = 33 // height

        return aSize
    }
}
