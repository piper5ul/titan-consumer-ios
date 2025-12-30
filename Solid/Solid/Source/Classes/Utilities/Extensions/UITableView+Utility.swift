//
//  UITableView+Utility.swift
//  Solid
//
//  Created by Solid iOS Team on 01/07/21.
//  Copyright © 2021 Solid. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {

    func drawCornersAroundSection(for indexPath: IndexPath, willDisplay cell: UITableViewCell) {

        let cornerRadius = Constants.cornerRadiusThroughApp
        var corners: UIRectCorner = []

        if indexPath.row == 0 {
            corners.update(with: .topLeft)
            corners.update(with: .topRight)
        }

        if indexPath.row == self.numberOfRows(inSection: indexPath.section) - 1 {
            corners.update(with: .bottomLeft)
            corners.update(with: .bottomRight)
        }

        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: cell.bounds,
                                      byRoundingCorners: corners,
                                      cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        cell.layer.mask = maskLayer
    }

    func drawCornerAroundTableView(for indexPath: IndexPath, willDisplay cell: UITableViewCell) {

        let cornerRadius = Constants.cornerRadiusThroughApp
        var corners: UIRectCorner = []
        let pathRef: CGMutablePath  = CGMutablePath()
        let bounds: CGRect  = cell.bounds // .insetBy(dx: 0, dy: 0)

        if indexPath.row == 0 && indexPath.row == self.numberOfRows(inSection: indexPath.section) - 1 {

            corners.update(with: .topLeft)
            corners.update(with: .topRight)
            corners.update(with: .bottomLeft)
            corners.update(with: .bottomRight)

            pathRef.__addRoundedRect(transform: nil, rect: bounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius)
        } else if indexPath.row == 0 {
            corners.update(with: .topLeft)
            corners.update(with: .topRight)

            pathRef.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
            pathRef.addArc(tangent1End: CGPoint(x: bounds.minX, y: bounds.minY), tangent2End: CGPoint(x: bounds.midX, y: bounds.minY), radius: cornerRadius)

            pathRef.addArc(tangent1End: CGPoint(x: bounds.maxX, y: bounds.minY), tangent2End: CGPoint(x: bounds.maxX, y: bounds.midY), radius: cornerRadius)
            pathRef.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        } else if indexPath.row == self.numberOfRows(inSection: indexPath.section) - 1 {
            corners.update(with: .bottomLeft)
            corners.update(with: .bottomRight)

            pathRef.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
            pathRef.addArc(tangent1End: CGPoint(x: bounds.minX, y: bounds.maxY), tangent2End: CGPoint(x: bounds.midX, y: bounds.maxY), radius: cornerRadius)

            pathRef.addArc(tangent1End: CGPoint(x: bounds.maxX, y: bounds.maxY), tangent2End: CGPoint(x: bounds.maxX, y: bounds.midY), radius: cornerRadius)
            pathRef.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
        } else {
            pathRef.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
            pathRef.addLine(to: CGPoint(x: bounds.minX, y: bounds.minY))
            pathRef.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))
            pathRef.move(to: CGPoint(x: bounds.maxX, y: bounds.minY))
            pathRef.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
            pathRef.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        }

        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: cell.bounds,
                                      byRoundingCorners: corners,
                                      cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        cell.layer.mask = maskLayer

        let borderPath = pathRef // maskLayer.path
        let borderLayer = CAShapeLayer()
        borderLayer.path = borderPath
        borderLayer.lineWidth = 1
        borderLayer.strokeColor = UIColor.customSeparatorColor.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.frame = cell.bounds
        cell.layer.addSublayer(borderLayer)
    }
}
