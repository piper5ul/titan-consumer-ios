//
//  AuthTextField.swift
//  Solid
//
//  Created by Solid iOS Team on 28/02/19.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit

class AuthTextField: UITextField {
    @IBOutlet weak var linkedErrorLabel: BaseErrorLabel?
    @IBOutlet weak var linkedDropDownButton: UIButton?
    @IBOutlet weak var passwordRevealButton: UIButton?

    @IBOutlet weak var enclosingView: UIView?
    @IBOutlet weak var seperator: UIView?
    @IBOutlet weak var accessoryLabel: UILabel?

    var xInset = CGFloat(20)

    enum FieldStatus: Int {
        case normal      = 0
        case highlighted = 1
        case error       = 2
    }

    @IBInspectable var disablePasteboard: Bool = false
    @IBInspectable var isMobileNumber: Bool = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupInitialUI()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInitialUI()
    }

    func setupInitialUI() {
        //self.layer.borderWidth = 0.5
        //self.layer.borderColor = UIColor.customSeparatorColor.withAlphaComponent(0.5).cgColor
        self.backgroundColor = .background

        if let revealButton = passwordRevealButton {
            self.isSecureTextEntry  = revealButton.isSelected
        }
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.x = self.frame.width - 5 - rect.width
        return rect
    }

    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        return true
    }

    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()

        return true
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var newXInset = xInset
        if self.isSecureTextEntry {
            var innerRect: CGRect = bounds
            innerRect.size.width = bounds.width - 2*newXInset - 40
            innerRect.origin.x = newXInset
            return innerRect
        }
        if isMobileNumber {
            newXInset += 20.0
        }
        return bounds.insetBy(dx: newXInset, dy: 0)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        debugPrint("editingRect of AuthTextField")
        var newXInset = xInset
        if self.isSecureTextEntry {
            var innerRect: CGRect = bounds
            innerRect.size.width = bounds.width - 2*newXInset - 40
            innerRect.origin.x = newXInset
            return innerRect
        }
        if isMobileNumber {
            newXInset += 20.0
        }
        return bounds.insetBy(dx: newXInset, dy: 0)
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if  disablePasteboard && (action == #selector(paste(_:)) || action == #selector(copy(_:)) || action == #selector(cut(_:))) {
            return false
        }

        return super .canPerformAction(action, withSender: sender)
    }

    @IBAction func toggleRevealPassword(_ sender: UIButton) {
        let theButton = passwordRevealButton ?? sender
        let currentStatus = theButton.isSelected
        let newStatus = !currentStatus
        theButton.isSelected = newStatus
        self.isSecureTextEntry = !newStatus
    }

    var status: FieldStatus = .normal {
        didSet {
            self.updateBorderColor()
        }
    }

     func updateBorderColor() {
        switch status {
            case .normal, .highlighted:
            self.linkedErrorLabel?.isHidden = true
            self.linkedErrorLabel?.text = ""
            setBorderColor(UIColor.customSeparatorColor)
        case .error:
            self.linkedErrorLabel?.isHidden = false
            setBorderColor(UIColor.redMain)
        }
     }

    func setBorderColor(_ color: UIColor) {
        if isMobileNumber {
            enclosingView?.layer.borderColor = color.cgColor
            seperator?.backgroundColor = color
            if status == .highlighted {
                accessoryLabel?.textColor = UIColor.redMain
            } else {
                accessoryLabel?.textColor = UIColor.customSeparatorColor
            }
        } else {
            self.layer.borderColor = color.cgColor
        }
    }

    func setIcon(_ image: UIImage) {

       let iconView = UIImageView(frame:
                      CGRect(x: 0, y: 0, width: 30, height: 30))
       iconView.image = image
       let iconContainerView: UIView = UIView(frame:
                      CGRect(x: 0, y: 0, width: 30, height: 30))
       iconContainerView.addSubview(iconView)
       rightView = iconContainerView
       rightViewMode = .always
    }
}
