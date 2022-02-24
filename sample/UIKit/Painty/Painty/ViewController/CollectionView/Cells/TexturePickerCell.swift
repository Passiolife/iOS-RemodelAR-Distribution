//
//  TexturePickerCell.swift
//  Painty
//
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit

final class TexturePickerCell: UICollectionViewCell {

    @IBOutlet weak var textureImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textureImageView.applyCornerRadius(radius: 15)
    }
}

//MARK: - Configure
extension TexturePickerCell {
    
    func configureCell(texture: String, indexPath: Int, selectedIndexPath: Int, showTexture: Bool) {
        
        textureImageView.image = UIImage(named: texture)
        
        textureImageView.applyBorder(with: (indexPath == selectedIndexPath && showTexture) ? 5 : 0, color: .white)
    }
}
