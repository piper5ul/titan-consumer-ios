//
//  UIView+Utility
//  Solid
//
//  Created by Solid iOS Team on 08/02/21.
//

import UIKit

extension UIView {

    // Corner Radius
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    // Border Width
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    // Border Color
    @IBInspectable var borderColor: UIColor {
        get {
            let color = layer.borderColor ?? UIColor.white.cgColor
            return UIColor(cgColor: color)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }

    // Shadow Radius
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }

    // Shadow Opacity
    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }

    // Shadow Offset
    @IBInspectable var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }

    // Shadow Color
    @IBInspectable var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }

    // Rounded view
    func setCircleShape() {
        let radius: CGFloat = self.bounds.size.width / 2.0
        self.layer.cornerRadius = radius
    }

    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }

    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.frame = self.bounds
        mask.path = path.cgPath
        self.layer.masksToBounds = true
        self.layer.mask = mask
    }

    func showWaitIndicator(inValue: Bool) {
        showWaitIndicator(inValue: inValue, backgroundAlpha: 0.5)
    }

    func showWaitIndicator(inValue: Bool, backgroundAlpha: CGFloat) {
        showWaitIndicatorInsideView(inValue: inValue, backgroundAlpha: backgroundAlpha)
    }

    func showWaitIndicatorInsideView(inValue: Bool, backgroundAlpha: CGFloat) {
        DispatchQueue.main.async {
            var container = self.viewWithTag(2002)
            var activityIndicator = container?.viewWithTag(2003) as? UIActivityIndicatorView
            container?.removeFromSuperview()

            container = nil
            activityIndicator?.removeFromSuperview()
            activityIndicator = nil
            if container == nil {
                container                   = UIView(frame: self.bounds)
                container?.backgroundColor  = .clear // UIColor(white: 0.0, alpha: backgroundAlpha)
                container?.tag               = 2002
                self.addSubview(container!)
                container?.autoresizingMask = [.flexibleWidth, .flexibleHeight]

                activityIndicator = UIActivityIndicatorView(style: .large)
                //            activityIndicator?.color = .gray
                container?.addSubview(activityIndicator!)
                activityIndicator?.center = (container?.center)!
                activityIndicator!.tag = 2003
                activityIndicator?.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
            }

            if inValue {
                self.bringSubviewToFront(container!)
                container?.frame = self.bounds
                container?.isHidden = false
                activityIndicator?.startAnimating()
            } else {
                container?.isHidden = true
                container?.removeFromSuperview()
                activityIndicator?.stopAnimating()

            }
        }
    }

    public func pin(to view: UIView) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    public func addShadowOnAllSides(_ shadowColor: UIColor = UIColor.primaryColor.withAlphaComponent(0.3)) {
        // *** Set masks bounds to NO to display shadow visible ***
        self.layer.masksToBounds = false
        // *** Set light gray color as shown in sample ***
        self.layer.shadowColor = shadowColor.cgColor
        // *** *** Use following to add Shadow top, left ***
        self.layer.shadowOffset = CGSize(width: -8.0, height: -8.0)

        // *** Use following to add Shadow bottom, right ***
        // self.avatarImageView.layer.shadowOffset = CGSizeMake(5.0f, 5.0f);

        // *** Use following to add Shadow top, left, bottom, right ***
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 5.0

        // *** Set shadowOpacity to full (1) ***
        self.layer.shadowOpacity = 0.2
    }

    func addDashedBorder(_ color: UIColor = UIColor.secondaryColor, withWidth width: CGFloat = 1, cornerRadius: CGFloat = Constants.cornerRadiusThroughApp + 2, dashPattern: [NSNumber] = [4, 4]) {

        self.layer.sublayers?.removeAll()
        
        let shapeLayer = CAShapeLayer()

        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.width/2, y: bounds.height/2)
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = width
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round // Updated in swift 4.2
        shapeLayer.lineDashPattern = dashPattern
        shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath

        self.layer.addSublayer(shapeLayer)
    }
}
