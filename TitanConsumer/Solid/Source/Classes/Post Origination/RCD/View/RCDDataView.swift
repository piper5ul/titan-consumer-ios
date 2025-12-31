//
//  RCDDataView.swift
//  Solid
//
//  Created by Solid iOS Team on 14/07/21.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit

class RCDDataView: UIView {

    let nibName = "RCDDataView"

    // AMOUNT
    @IBOutlet weak var amountTitleLabel: UILabel!
    @IBOutlet weak var amountValueLabel: UILabel!

    // TO
	@IBOutlet weak var imgseparator: UIImageView!
    @IBOutlet weak var depositeTitleLabel: UILabel!
    @IBOutlet weak var toAccNameLabel: UILabel!
    @IBOutlet weak var toAccNumberLabel: UILabel!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        guard let contentView = loadView() else { return }
        contentView.frame = bounds
        addSubview(contentView)
    }

    func loadView() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupRCDDataUI()
    }

    func setupRCDDataUI() {
		let titleFont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize14
		let valueFont = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14

        amountTitleLabel.font = titleFont
        amountTitleLabel.textColor = UIColor.secondaryColor
        amountTitleLabel.textAlignment = .left

        amountValueLabel.font = valueFont
        amountValueLabel.textAlignment = .left
        amountValueLabel.textColor = UIColor.primaryColor

        depositeTitleLabel.font = titleFont
        depositeTitleLabel.textColor = UIColor.secondaryColor
        depositeTitleLabel.textAlignment = .left

        toAccNameLabel.font = valueFont
        toAccNameLabel.textColor = UIColor.primaryColor
        toAccNameLabel.textAlignment = .left

        toAccNumberLabel.font = titleFont
        toAccNumberLabel.textColor = UIColor.secondaryColor
        toAccNumberLabel.textAlignment = .left
		imgseparator.backgroundColor = UIColor.customSeparatorColor
        
        self.backgroundColor = .background
        self.layer.borderColor = UIColor.customSeparatorColor.cgColor
    }

    func setRCDData(accountType: AccountType, viewModel: RCDViewModel) {
        if accountType == .personalChecking {
            if let name = AppGlobalData.shared().personData.name {
                toAccNameLabel.text = name
            }
        } else {
            if let selectedBusiness = AppGlobalData.shared().businessData, let name = selectedBusiness.legalName {
                toAccNameLabel.text = name
            }
        }

        if let acc = AppGlobalData.shared().accountData, let accName = acc.label {
            toAccNumberLabel.text = accName// "\(checkingString) \(accNoString)"
        }

        let amountString = viewModel.amountString
        amountValueLabel.text = amountString
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        amountTitleLabel.textColor = UIColor.secondaryColor
        amountValueLabel.textColor = UIColor.primaryColor
        depositeTitleLabel.textColor = UIColor.secondaryColor
        toAccNameLabel.textColor = UIColor.primaryColor
        toAccNumberLabel.textColor = UIColor.secondaryColor
        self.layer.borderColor = UIColor.customSeparatorColor.cgColor
        imgseparator.backgroundColor = UIColor.customSeparatorColor
    }
}
