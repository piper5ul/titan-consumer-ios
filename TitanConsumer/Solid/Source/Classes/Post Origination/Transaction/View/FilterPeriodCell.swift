//
//  FilterPeriodCell.swift
//  Solid
//
//  Created by Solid iOS Team on 16/03/21.
//

import UIKit

// MARK: - FilterPeriodCellDelegate
@objc protocol PeriodCellDelegate {
    func periodFrom(startDate: Date)
    func periodTo(endDate: Date)
    func selectedPeriodRadioButton(cell: FilterPeriodCell)
}

class FilterPeriodCell: UITableViewCell {

    @IBOutlet var txtFrom: BaseTextField!
    @IBOutlet var txtTo: BaseTextField!

    @IBOutlet var lblFrom: UILabel!
    @IBOutlet var lblTo: UILabel!

    @IBOutlet var radioButton: BaseButton!
    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var stackView: UIStackView!
    @IBOutlet var stkViewHeight: NSLayoutConstraint!

    var indexPath: IndexPath?

    weak var periodDelegate: PeriodCellDelegate?

    let datePicker = UIDatePicker()

    var isRadiobuttonSelected: Bool? {
        didSet {
            radioButton.isSelected = isRadiobuttonSelected ?? false
        }
    }

    var isStackViewHidden: Bool? {
        didSet {
            stackView.isHidden = isStackViewHidden ?? false
            stkViewHeight.constant = stackView.isHidden ? 0 : 71.5
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.backgroundColor = .clear
		let labelFont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize12
        self.lblFrom?.font = labelFont
        self.lblFrom?.textColor = UIColor.secondaryColor
        self.lblTo?.font = labelFont
        self.lblTo?.textColor = UIColor.secondaryColor

        self.lblFrom?.text = Utility.localizedString(forKey: "from")
        self.lblTo?.text = Utility.localizedString(forKey: "to")

        self.txtFrom.delegate = self
        self.txtTo.delegate = self
		let titleFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
        self.titleLabel?.text = Utility.localizedString(forKey: "custom")
        self.titleLabel?.font = titleFont
        self.titleLabel?.textColor = UIColor.primaryColor

        self.radioButton.setImage(UIImage(named: "radioButton_deselected"), for: .normal)
        self.radioButton.setImage(UIImage(named: "radioButton_selected"), for: .selected)
        self.radioButton.imageView?.tintColor = .brandColor

        self.radioButton.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func radioButtonSelected(sender: UIButton) {

        if !sender.isSelected {
            sender.isSelected = true

            periodDelegate?.selectedPeriodRadioButton(cell: self)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.radioButton.imageView?.tintColor = .brandColor
        self.lblFrom?.textColor = UIColor.secondaryColor
        self.lblTo?.textColor = UIColor.secondaryColor
        self.titleLabel?.textColor = UIColor.primaryColor
    }
}

// MARK: - UITextField
extension FilterPeriodCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setDatePicker(forTextField: textField)
    }
}

// MARK: - Set Picker
extension FilterPeriodCell {

    func setDatePicker(forTextField: UITextField) {

        let toolbar = UIToolbar()

        datePicker.datePickerMode = .date
        datePicker.backgroundColor = .white
        datePicker.setValue(UIColor.primaryColor, forKey: "textColor")

        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels

            if datePicker.subviews.count > 0 {
                datePicker.subviews[0].subviews[0].backgroundColor = .background
            }
        }

        datePicker.maximumDate = Date()

        toolbar.sizeToFit()

        var doneButton = UIBarButtonItem()

        if forTextField == txtFrom {
            doneButton = UIBarButtonItem(title: Utility.localizedString(forKey: "done"), style: .plain, target: self, action: #selector(doneFromDatePicker))
        } else {
            doneButton = UIBarButtonItem(title: Utility.localizedString(forKey: "done"), style: .plain, target: self, action: #selector(doneToDatePicker))
        }

        doneButton.tintColor = .primaryColor

        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: Utility.localizedString(forKey: "cancel"), style: .plain, target: self, action: #selector(cancelDatePicker))
        cancelButton.tintColor = .primaryColor

        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)

        forTextField.inputAccessoryView = toolbar
        forTextField.inputView = datePicker
    }

    @objc func doneToDatePicker() {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.txtTo!.text = formatter.string(from: datePicker.date)
        self.endEditing(true)

        periodDelegate?.periodTo(endDate: datePicker.date)
    }

    @objc func doneFromDatePicker() {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.txtFrom!.text = formatter.string(from: datePicker.date)
        self.endEditing(true)

        periodDelegate?.periodFrom(startDate: datePicker.date)
    }

    @objc func cancelDatePicker() {
        self.endEditing(true)
    }
}
