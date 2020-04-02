//
//  UIView + Extensions.swift
//  Wiggle
//
//  Created by Murat Turan on 23.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit

public enum UIViewBorderSide {
    case top, bottom, left, right, center
}

extension UIView {
    func addShadow(_ shadowColor: UIColor = UIColor.black, shadowRadiues: CGFloat = 1, shadowOpacity: Float = 0.2, shadowOffset: CGSize = CGSize(width: 0, height: 2)) {
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowRadius = shadowRadiues
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset = shadowOffset
    }
    
    func round(_ corners: UIRectCorner, radius: CGFloat) {
        _ = _round(corners, radius: radius)
    }

    func round(_ corners: UIRectCorner, radius: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
        let mask = _round(corners, radius: radius)
        addBorder(mask, borderColor: borderColor, borderWidth: borderWidth)
    }

    func fullyRound(_ diameter: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
        layer.masksToBounds = true
        layer.cornerRadius = diameter / 2
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
    }
    
    func addBorder(_ side: UIViewBorderSide, color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor

        switch side {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: width)
        case .bottom:
            border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        case .right:
            border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        case .center:
            border.frame = CGRect(x: 0, y: (self.frame.size.height - width) / 2, width: self.frame.size.width, height: width)
        }

        self.layer.addSublayer(border)
    }

    func addBorder(_ color: UIColor, width: CGFloat) {
        self.changeBorderWidth(width)
        self.changeBorderColor(color)
    }
    
    func changeBorderWidth(_ width: CGFloat) {
        self.layer.borderWidth = width
    }

    func changeBorderColor(_ color: UIColor) {
        self.layer.borderColor = color.cgColor
    }

    func cornerRadius(_ cornerRadius: CGFloat) {
        self.layer.cornerRadius = cornerRadius
    }

    func fullyRound(_ cornerRadius: CGFloat) {
        self.layer.cornerRadius = cornerRadius
    }
    
    func _round(_ corners: UIRectCorner, radius: CGFloat) -> CAShapeLayer {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        return mask
    }

    func addBorder(_ mask: CAShapeLayer, borderColor: UIColor, borderWidth: CGFloat) {
        let borderLayer = CAShapeLayer()
        borderLayer.path = mask.path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.lineWidth = borderWidth
        borderLayer.frame = bounds
        layer.addSublayer(borderLayer)
    }
}

extension CALayer {
      func applyShadow(
      color: UIColor = .black,
      alpha: Float = 0.5,
      x: CGFloat = 0,
      y: CGFloat = 2,
      blur: CGFloat = 4,
      spread: CGFloat = 0)
    {
      shadowColor = color.cgColor
      shadowOpacity = alpha
      shadowOffset = CGSize(width: x, height: y)
      shadowRadius = blur / 2.0
      if spread == 0 {
        shadowPath = nil
      } else {
        let dx = -spread
        let rect = bounds.insetBy(dx: dx, dy: dx)
        shadowPath = UIBezierPath(rect: rect).cgPath
      }
    }
}

extension UIView {
    func setGradientBackground(colorOne: UIColor = UIColor(hexString: "223C53"), colorTwo: UIColor = UIColor(hexString: "071930")) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.05)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.95)
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setWhiteGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.white.withAlphaComponent(0.21).cgColor, UIColor.white.withAlphaComponent(0.06).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.05)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.95)
        layer.insertSublayer(gradientLayer, at: 0)
    }
}

