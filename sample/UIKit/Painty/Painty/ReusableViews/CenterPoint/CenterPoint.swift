//
//  CenterPoint.swift
//  Painty
//
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit

final class CenterPoint: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var innerCircle: UIView!
    @IBOutlet weak var outerCircle: UIView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSubviews()
    }
    
    private func initSubviews() {
        
        let nib = UINib(nibName: "CenterPoint", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        
        contentView.frame = bounds
        addSubview(contentView)
        
        applyCircleToView()
    }
}

//MARK: - Configure CenterPoint View
extension CenterPoint {
    
    private func applyCircleToView() {
        
        innerCircle.layer.cornerRadius = innerCircle.bounds.width / 2
        outerCircle.layer.cornerRadius = outerCircle.bounds.width / 2
        
        innerCircle.applyBorder(with: 1, color: .systemBlue)
        outerCircle.applyBorder(with: 2, color: .systemBlue)
    }
}
