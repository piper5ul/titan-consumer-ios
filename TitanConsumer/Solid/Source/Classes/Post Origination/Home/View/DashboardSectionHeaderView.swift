//
//  DashboardSectionHeaderView.swift
//  Solid
//
//  Created by Solid iOS Team on 22/02/21.
//

import Foundation
import UIKit

class DashboardSectionHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var imgViewRightIcon: BaseImageView!
    @IBOutlet weak var lblRightTitle: UILabel!
    @IBOutlet weak var lblHeaderTitle: UILabel!
    @IBOutlet weak var lblSubHeaderTitle: UILabel!
    @IBOutlet weak var btnViewAll: UIButton!

    @IBOutlet weak var imgViewLeftIcon: BaseImageView!

    var titleString: String = "" {
        didSet {
            lblHeaderTitle?.text = titleString
        }
    }

    var subTitleString: String = "" {
        didSet {
            lblSubHeaderTitle.isHidden = subTitleString.isEmpty
            lblSubHeaderTitle?.text = subTitleString
        }
    }

    var rightTitleString: String = "" {
        didSet {
            lblRightTitle?.text = rightTitleString
        }
    }

    var iconName: String = "" {
        didSet {
            if !iconName.isEmpty {
                imgViewRightIcon.image = UIImage(named: iconName)
            }
        }
    }

    var leftIconName: String = "" {
        didSet {
            if !leftIconName.isEmpty {
                imgViewLeftIcon.image = UIImage(named: leftIconName)
            }
        }
    }

    override func awakeFromNib() {
        self.contentView.backgroundColor = .grayBackgroundColor //UIColor.background

        lblRightTitle.font = UIFont.sfProDisplayRegular(fontSize: 14.0)
        lblRightTitle.textColor = UIColor.secondaryColor

        lblSubHeaderTitle.font = UIFont.sfProDisplayRegular(fontSize: 13.0)
        lblSubHeaderTitle.textColor = UIColor.primaryColor
        lblHeaderTitle.font = Constants.commonFont
        lblHeaderTitle.textColor = UIColor.primaryColor
        lblHeaderTitle.numberOfLines = 0
        lblHeaderTitle.textAlignment = .left
        
        imgViewRightIcon.customTintColor = .secondaryColor
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblRightTitle.textColor = UIColor.secondaryColor
        lblSubHeaderTitle.textColor = UIColor.primaryColor
        lblHeaderTitle.textColor = UIColor.primaryColor
        imgViewRightIcon.customTintColor = .secondaryColor
    }
}
