//
//  OwnerListCell.swift
//  Solid
//
//  Created by Solid iOS Team on 24/02/21.
//

import UIKit

protocol OwnerListCellDelegate {
    func ownerListCell(cell: OwnerListCell, begin cd: BaseTextField?)

    //FOR IS CONTROL PERSON CHECK
    func controlPersonCheck(forIndexPath: IndexPath, isSelected: Bool?)
    
    //FOR DESIGNATION PICKER
    func selectedDesignation(forIndexPath: IndexPath, selectedData: ListItems?)
    
    //FOR ENTERED TITLE
    func enteredTitle(forIndexPath: IndexPath, changed data: String?)
}

class OwnerListCell: UITableViewCell {
    var delegate: OwnerListCellDelegate?
    
    @IBOutlet var btnControlPersonCheck: UIButton?
    @IBOutlet var lblControlPersonCheck: UILabel?
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPercentage: UILabel!
    
    @IBOutlet var lblDesignation: UILabel?
    @IBOutlet var txtDesignation: BaseTextField?

    @IBOutlet var lblTitle: UILabel?
    @IBOutlet var txtTitle: BaseTextField?

    @IBOutlet var titleView: UIView?

    var arrPickerData: [ListItems] = []
    var pickerView = UIPickerView()
        
    var indexPath: IndexPath?

    var isCheckboxSelected: Bool? {
        didSet {
            btnControlPersonCheck?.isSelected = isCheckboxSelected ?? false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        txtTitle?.keyboardType = .alphabet
        
        self.setUI()
    }

    func setUI() {
        let cpFont = Utility.isDeviceIpad() ? Constants.boldFontSize16 : Constants.boldFontSize14
        lblControlPersonCheck?.font = cpFont
        lblControlPersonCheck?.textColor = UIColor.primaryColor
        
        let nameFont = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
        lblName.font = nameFont
        lblPercentage.font = nameFont
        lblName.textColor = UIColor.primaryColor
        lblPercentage.textColor = UIColor.primaryColor
        
        let titlefont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize12
        lblDesignation?.font = titlefont
        lblTitle?.font = titlefont
       
        lblDesignation?.textColor = UIColor.secondaryColorWithOpacity
        lblTitle?.textColor = UIColor.secondaryColorWithOpacity
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        titleView?.isHidden = true
                
        lblControlPersonCheck?.text = Utility.localizedString(forKey: "control_person")
        lblDesignation?.text = Utility.localizedString(forKey: "designation")
        lblTitle?.text = Utility.localizedString(forKey: "Title")
        
        btnControlPersonCheck?.setImage(UIImage(named: "checkbox_unSelected"), for: .normal)
        btnControlPersonCheck?.setImage(UIImage(named: "checkbox_selected"), for: .selected)
        btnControlPersonCheck?.backgroundColor = .clear
        btnControlPersonCheck?.imageView?.tintColor = .primaryColor
        
        txtDesignation?.placeholderString = "select.."
        self.backgroundColor = .background
    }

    @IBAction func controlPersonCheckboxClicked(sender: UIButton) {
        sender.isSelected = !sender.isSelected

        delegate?.controlPersonCheck(forIndexPath: self.indexPath!, isSelected: sender.isSelected)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblName.textColor = UIColor.primaryColor
        lblPercentage.textColor = UIColor.primaryColor
    }
}

// MARK: - Set TextField
extension OwnerListCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
        
        delegate?.ownerListCell(cell: self, begin: nil)
        
        textField.returnKeyType = .done

        if textField == txtDesignation {
            setPicker()
        } else {
            self.txtTitle?.inputView = nil
            self.txtTitle?.inputAccessoryView = nil
            self.txtTitle?.autocapitalizationType = .words
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let theString = textField.text! as NSString
        let theNewString = theString.replacingCharacters(in: range, with: string).trim

        delegate?.enteredTitle(forIndexPath: self.indexPath!, changed: theNewString)

        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return false
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }

    func validateEnteredText(enteredText: String) {
        if enteredText.isInvalidInput() {
            self.txtTitle?.status = .error
            self.txtTitle?.linkedErrorLabel?.text = Utility.localizedString(forKey: "invalid_input")
        } else {
            self.txtTitle?.status = .normal
        }
    }
}

// MARK: - Set Picker
extension OwnerListCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func setPicker() {
        pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        
        let toolbar = UIToolbar()

        pickerView.backgroundColor = .background
        pickerView.setValue(UIColor.primaryColor, forKey: "textColor")

        if #available(iOS 13.4, *) {
            if pickerView.subviews.count > 0 {
                pickerView.subviews[0].subviews[0].backgroundColor = .background
            }
        }

        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: Utility.localizedString(forKey: "done"), style: .plain, target: self, action: #selector(donePicker))
        doneButton.tintColor = .primaryColor

        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: Utility.localizedString(forKey: "cancel"), style: .plain, target: self, action: #selector(cancelDatePicker))
        cancelButton.tintColor = .primaryColor

        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)

        self.txtDesignation?.inputAccessoryView = toolbar
        self.txtDesignation?.inputView = pickerView
    }

    @objc func donePicker() {
        let pickerLabel: UILabel? = (self.pickerView.view(forRow: self.pickerView.selectedRow(inComponent: 0), forComponent: 0) as? UILabel)
        
        self.txtDesignation!.text = pickerLabel?.text
        
        self.endEditing(true)
        
        if arrPickerData.count > 0 {
            delegate?.selectedDesignation(forIndexPath: self.indexPath!, selectedData: arrPickerData[self.pickerView.selectedRow(inComponent: 0)])
        }
    }
    
    @objc func cancelDatePicker() {
        self.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrPickerData.count
    }

    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This is a required method.
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label : UILabel
        if view == nil {
            label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: UIFont.systemFont(ofSize: 20).lineHeight * UIScreen.main.scale))
            label.textAlignment = .center
            label.numberOfLines = 2
            label.lineBreakMode = .byWordWrapping
            label.autoresizingMask = .flexibleWidth
            label.font = UIFont.systemFont(ofSize: 20)
        } else {
            label = view as! UILabel
        }
        
        if row < arrPickerData.count {
            if let strText = arrPickerData[row].title, !strText.isEmpty {
                label.text = strText
            }
        }
        
        return label;
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return UIFont.systemFont(ofSize: 20).lineHeight * UIScreen.main.scale
    }
}


