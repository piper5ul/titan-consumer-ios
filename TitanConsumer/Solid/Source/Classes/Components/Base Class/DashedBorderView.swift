//
//  DashedBorderView.swift
//  Solid
//
//  Created by Solid iOS Team on 12/05/21.
//

import Foundation
import UIKit

class DashedBorderView: UIView {

    var aCornerRadius: CGFloat = Constants.cornerRadiusThroughApp {
        didSet {
            layer.cornerRadius = aCornerRadius
            layer.masksToBounds = aCornerRadius > 0
        }
    }
//    var dashWidth: CGFloat = 1
//    var dashColor: UIColor = .primaryColor
    var dashLength: CGFloat = 4
    var betweenDashesSpace: CGFloat = 4

    var dashBorder: CAShapeLayer?

    init(color: UIColor, width: CGFloat = 1) {
        super.init(frame: CGRect.zero)
        let dashedBorder = CAShapeLayer()
        dashedBorder.lineWidth = width
        dashedBorder.strokeColor = color.cgColor
        dashedBorder.lineDashPattern = [dashLength, betweenDashesSpace] as [NSNumber]
        dashedBorder.frame = bounds
        dashedBorder.fillColor = nil
        if aCornerRadius > 0 {
            dashedBorder.path = UIBezierPath(roundedRect: bounds, cornerRadius: aCornerRadius).cgPath
        } else {
            dashedBorder.path = UIBezierPath(rect: bounds).cgPath
        }
        layer.addSublayer(dashedBorder)

        aCornerRadius = Constants.cornerRadiusThroughApp + 2
        layer.cornerRadius = aCornerRadius
        layer.masksToBounds = aCornerRadius > 0

        self.dashBorder = dashedBorder

//        self.layoutSubviews()
    }

    override func draw(_ rect: CGRect) {
        dashBorder?.frame = rect
        dashBorder?.path = UIBezierPath(roundedRect: rect, cornerRadius: layer.cornerRadius).cgPath
    }

    required init?(coder: NSCoder) {
        // fatalError("init(coder:) has not been implemented")
        super.init(coder: coder)
    }
}
