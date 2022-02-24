//
//  ColorPickerCell.swift
//  Painty
//
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit

final class ColorPickerCell: UICollectionViewCell {
    @IBOutlet weak var colorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        colorView.applyCornerRadius(radius: 15)
    }
}

//MARK: - Configure
extension ColorPickerCell {
    func configureCell(color: UIColor, indexPath: Int, selectedIndexPath: Int) {
        
        colorView.backgroundColor = color
        colorView.applyBorder(with: indexPath == selectedIndexPath ? 5 : 0, color: .white)
    }
}
