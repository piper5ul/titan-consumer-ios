//
//  PINOTPTextField.swift
//  Solid
//
//  Created by Solid iOS Team on 21/12/21.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit

class PINOTPTextField: UITextField {
    /// Border color info for field
    
    //var borderColor = UIColor.black
    var borderColorPin: UIColor = UIColor(red: 0.93, green: 0.938, blue: 0.946, alpha: 1)
    
    /// Border width info for field
    var borderWidthPin: CGFloat = 2
    
    var shapeLayer: CAShapeLayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initalizeUI(forFieldType type: PINOTPView.DisplayType) {
        switch type {
        case .circular:
            layer.cornerRadius = bounds.size.width / 2
        case .square:
            layer.cornerRadius = 3
        case .diamond:
            addDiamondMask()
        case .underlinedBottom:
            addBottomView()
        }
        
        // Basic UI setup
        if type != .diamond && type != .underlinedBottom {
            layer.borderColor = borderColorPin.cgColor
            layer.borderWidth = borderWidthPin
        }
        
        autocorrectionType = .no
        textAlignment = .center
    }
    
    override func deleteBackward() {
        super.deleteBackward()
        _ = delegate?.textField?(self, shouldChangeCharactersIn: NSMakeRange(0, 0), replacementString: "")
    }
    
    // Helper function to create diamond view
    fileprivate func addDiamondMask() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.size.width / 2.0, y: 0))
        path.addLine(to: CGPoint(x: bounds.size.width, y: bounds.size.height / 2.0))
        path.addLine(to: CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height))
        path.addLine(to: CGPoint(x: 0, y: bounds.size.height / 2.0))
        path.close()
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        
        layer.mask = maskLayer
        
        shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = borderWidthPin
        shapeLayer.fillColor = backgroundColor?.cgColor
        shapeLayer.strokeColor = borderColorPin.cgColor
        
        layer.addSublayer(shapeLayer)
    }
    
    // Helper function to create a underlined bottom view
    fileprivate func addBottomView() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: bounds.size.height))
        path.addLine(to: CGPoint(x: bounds.size.width, y: bounds.size.height))
        path.close()
        
        shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = borderWidthPin
        shapeLayer.fillColor = backgroundColor?.cgColor
        shapeLayer.strokeColor = borderColorPin.cgColor
        
        layer.addSublayer(shapeLayer)
    }
}
