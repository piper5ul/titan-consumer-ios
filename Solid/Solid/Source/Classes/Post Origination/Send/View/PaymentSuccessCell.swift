//
//  PaymentSuccessCell.swift
//  Solid
//
//  Created by Solid iOS Team on 09/03/21.
//

import Foundation
import UIKit

class PaymentSuccessCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var vwAnimationContainer: BaseAnimationView?

    var cellEmailPress: (() -> Void)?

    var titleString: String = "" {
        didSet {
            lblTitle?.text = titleString
        }
    }

    var descriptionString: String = "" {
        didSet {
            lblDescription?.text = descriptionString
        }
    }

    var animationImageName: String = "" {
        didSet {
            if !animationImageName.isEmpty {
                vwAnimationContainer?.animationFile = animationImageName
            }
        }
    }
    
    override func awakeFromNib() {
        lblTitle.font = UIFont.sfProDisplayRegular(fontSize: 24)
        lblTitle.textColor = UIColor.primaryColor

        lblDescription.font = UIFont.sfProDisplayRegular(fontSize: 14.0)
        lblDescription.textColor = UIColor.secondaryColorWithOpacity

        lblTitle.textAlignment = .center
        lblDescription.textAlignment = .center
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblTitle.textColor = UIColor.primaryColor
        lblDescription.textColor = UIColor.secondaryColorWithOpacity
    }
}
