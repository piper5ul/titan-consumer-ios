//
//  DashboardCell.swift
//  Solid
//
//  Created by Solid iOS Team on 22/02/21.
//

import Foundation
import UIKit
import SkeletonView

enum DashboardCellType {
    case labelAccessory
    case buttonAccessory
    case imageAccessory
}

class DashboardCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var labelContainerView: UIView!
    @IBOutlet weak var imageContainerView: UIView!

    @IBOutlet weak var imgVwAccesory: BaseImageView!
    @IBOutlet weak var heightConstImageVwAccessory: NSLayoutConstraint!
    @IBOutlet weak var widthConstImgVwAccessory: NSLayoutConstraint!
    @IBOutlet weak var lblAccesory: UILabel!
    @IBOutlet weak var btnAccesory: BaseButton!

    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var topConstForMainStackView: NSLayoutConstraint!
    @IBOutlet weak var bottomConstForMainStackView: NSLayoutConstraint!

    @IBOutlet weak var accTypeContainerView: UIView!
    @IBOutlet weak var lblAccType: UILabel!
    @IBOutlet weak var accTypeColoredBgView: UIView!
    @IBOutlet weak var accTypeWhiteBgView: UIView!

    var indexPath: IndexPath!

    var model: DashboardCellModel?

    let buttonViewContainerWidth: CGFloat = 65.0
    let labelViewContainerWidth: CGFloat = 29.0
    let imageContainerViewWidth: CGFloat = 16.0

    override func awakeFromNib() {
		let labelFont = Utility.isDeviceIpad() ? Constants.mediumFontSize18: Constants.mediumFontSize14
		let descFont = Utility.isDeviceIpad() ? Constants.mediumFontSize14: Constants.mediumFontSize12

        self.titleLabel.font = labelFont
        
        self.descriptionLabel.font = descFont
        self.descriptionLabel.textColor = UIColor.secondaryColor

        imgVwAccesory.image = UIImage(named: "Chevron-right-grey")
        imgVwAccesory.contentMode = .scaleAspectFit

        btnAccesory.set(title: Utility.localizedString(forKey: "dashboard_cell_details"))
        btnAccesory.titleLabel?.font = descFont
        btnAccesory.setTitleColor(UIColor.primaryColor, for: .normal)

        lblAccesory.text = "+ $520.50"

        lblAccType.font = descFont
        lblAccType.textAlignment = .center
        lblAccType.layer.cornerRadius = Constants.cornerRadiusThroughApp
        lblAccType.layer.masksToBounds = true
        
        accTypeColoredBgView.layer.cornerRadius = Constants.cornerRadiusThroughApp
        accTypeColoredBgView.layer.masksToBounds = true
        		
        accTypeWhiteBgView.backgroundColor = .white
        accTypeWhiteBgView.alpha = 0.60
        accTypeWhiteBgView.layer.cornerRadius = Constants.cornerRadiusThroughApp
        accTypeWhiteBgView.layer.masksToBounds = true
        
		self.titleLabel.letterSpace = 0.32
		self.descriptionLabel.letterSpace = 0.24
		
        self.contentView.layer.cornerRadius = Constants.cornerRadiusThroughApp
        
        self.mainContainerView.backgroundColor = .background
        
        self.titleLabel.textColor = .primaryColor
        accTypeContainerView.isHidden = true
    }

    func configure(withModel model: DashboardCellModel) {
        if let aTitleValue = model.titleValue {
            titleLabel.text = aTitleValue
			self.titleLabel.letterSpace = 0.02
        }
		
		if let aDescriptionValue = model.descriptionValue {
            descriptionLabel.text = aDescriptionValue
			self.descriptionLabel.letterSpace = 0.02
        }

        if let accessoryType = model.cellType {
            setCellType(accessoryType: accessoryType)
        }
        
        accTypeContainerView.isHidden = true
        
        self.model = model
    }

    func setCellType(accessoryType: DashboardCellType) {

        switch accessoryType {
            case .buttonAccessory:
                buttonContainerView.isHidden = false
                labelContainerView.isHidden = true
                imageContainerView.isHidden = true
                buttonContainerView.widthAnchor.constraint(equalToConstant: buttonViewContainerWidth).isActive = true

            case .imageAccessory:
                buttonContainerView.isHidden = true
                labelContainerView.isHidden = true
                imageContainerView.isHidden = false
                imageContainerView.widthAnchor.constraint(equalToConstant: imageContainerViewWidth).isActive = true

            case .labelAccessory:
                buttonContainerView.isHidden = true
                labelContainerView.isHidden = false
                imageContainerView.isHidden = true
                labelContainerView.widthAnchor.constraint(equalToConstant: labelViewContainerWidth).isActive = true
        }
    }

    func configureForAccounts(accountModel: AccountDataModel) {
        self.topConstForMainStackView.constant  = Utility.isDeviceIpad() ? 10.0 : 4.0
        self.bottomConstForMainStackView.constant = Utility.isDeviceIpad() ? 10.0 : 4.0
        self.heightConstImageVwAccessory.constant = 40
        self.widthConstImgVwAccessory.constant = 40
        
        accTypeContainerView.isHidden = false
        
        if let balance = accountModel.availableBalance {
            let formatted = Utility.getFormattedAmount(amount: balance)
            let strBalance = Utility.localizedString(forKey: "dashboard_row_balance_title")
            descriptionLabel.text = "\(strBalance)  \(formatted)"
        }
        
        if let accName = accountModel.label {
            titleLabel.text = accName //"\(accName) \(accNum)"
        }
        
        if let accType = accountModel.type, accType != .unknown {
            lblAccType.text = accType.localizeType()
            accTypeColoredBgView.backgroundColor = accType.colorForType().withAlphaComponent(0.3)
            lblAccType.textColor = accType.colorForType()
        }
        
        imgVwAccesory.image = UIImage(named: "Chevron-right-grey")
        self.mainContainerView.borderColor = .clear
        setCellType(accessoryType: .imageAccessory)
        imgVwAccesory.contentMode = .center
        
        imgVwAccesory.isHidden = true
    }

    @IBAction func accessoryButtonClicked(_ sender: UIButton) {
        // This method is required.
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.titleLabel.textColor = .primaryColor
        self.descriptionLabel.textColor = .secondaryColor
    }
}

class DashboardCellModel {
    var selected: Bool = false
    var cellType: DashboardCellType?
    var sectionName: String?
    var titleValue: String?
    var descriptionValue: String?
    var descriptionValue2: String?
}
