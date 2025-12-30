//
//  ButtonFooterView.swift
//  Solid
//
//  Created by Solid iOS Team on 13/05/21.
//

import Foundation
import UIKit

class ButtonFooterView: UIView {

    let nibName = "ButtonFooterView"

    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var separatorImgV: UIImageView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnApply: ColoredButton!

    @IBOutlet var leftButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet var rightButtonLeadingConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }

    private func nibSetup() {
        guard let view = loadViewFromNib() else { return }
        view.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        setupUI()
        self.addSubview(view)
    }

    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

    override func awakeFromNib() {
        self.setupUI()
    }

    func setupUI() {
		let titleFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
        btnClose.titleLabel?.font = titleFont
        btnClose.setTitleColor(UIColor.primaryColor, for: .normal)
        btnClose.cornerRadius = Constants.cornerRadiusThroughApp
        btnClose.layer.masksToBounds = true
        btnClose.borderWidth = 1
        btnClose.borderColor = .primaryColor
        
        separatorImgV.backgroundColor = UIColor.customSeparatorColor
        
        footerView.backgroundColor = .background
        
        btnApply.isEnabled = true
    }

    func configureButtons(havingTwoButtons: Bool = false, leftButtonTitle: String = Utility.localizedString(forKey: "previous"), rightButtonTitle: String = Utility.localizedString(forKey: "next")) {

        if havingTwoButtons {
            btnClose.setTitle(leftButtonTitle, for: .normal)
            btnApply.setTitle(rightButtonTitle, for: .normal)
            NSLayoutConstraint.setMultiplier(0.45, of: &leftButtonWidthConstraint)
        } else {
            NSLayoutConstraint.setMultiplier(0.0, of: &leftButtonWidthConstraint)
            rightButtonLeadingConstraint.constant = 0
            btnApply.setTitle(rightButtonTitle, for: .normal)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        btnClose.borderColor = .primaryColor
        btnClose.setTitleColor(UIColor.primaryColor, for: .normal)
    }
}

extension NSLayoutConstraint {
    static func setMultiplier(_ multiplier: CGFloat, of constraint: inout NSLayoutConstraint) {
        NSLayoutConstraint.deactivate([constraint])

        let newConstraint = NSLayoutConstraint(item: constraint.firstItem as Any, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: constraint.secondItem, attribute: constraint.secondAttribute, multiplier: multiplier, constant: constraint.constant)

        newConstraint.priority = constraint.priority
        newConstraint.shouldBeArchived = constraint.shouldBeArchived
        newConstraint.identifier = constraint.identifier

        NSLayoutConstraint.activate([newConstraint])
        constraint = newConstraint
    }
}
