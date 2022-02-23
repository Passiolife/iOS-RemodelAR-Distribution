//
//  UIView+Extension.swift
//  iOS-AR-Remodel-Module-UIKit
//
//  Created by mac-0002 on 03/12/21.
//

import UIKit

extension UIView {
    
    func applyCornerRadius(radius: CGFloat) {
        layer.cornerRadius = radius
    }
    
    func applyBorder(with width: CGFloat, color: UIColor) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
}
