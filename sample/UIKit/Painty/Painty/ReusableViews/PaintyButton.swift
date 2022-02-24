//
//  PaintyButton.swift
//  Painty
//
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit

@IBDesignable class PaintyButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    @IBInspectable var cornerRadius: CGFloat = 10 {
        didSet {
            refreshCorners(value: cornerRadius)
        }
    }
    
    private func sharedInit() {
        refreshCorners(value: cornerRadius)
    }
    
    private func refreshCorners(value: CGFloat) {
        layer.cornerRadius = value
    }
}
