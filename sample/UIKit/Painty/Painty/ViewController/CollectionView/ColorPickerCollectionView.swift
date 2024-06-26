//
//  ColorPickerCollectionView.swift
//  Painty
//
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit
import RemodelAR

final class ColorPickerCollectionView: UICollectionView {
    
    var colorPicker = [ColorPicker]() {
        didSet {
            reloadData()
        }
    }
    
    public var didSelectColor: ((WallPaint) -> Void)?
    
    private let cellIdentidfier = "ColorPickerCell"
    private var selectedColor = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
    }
}

//MARK: - Configure
extension ColorPickerCollectionView {
    private func configure() {
        delegate = self
        dataSource = self
        register(UINib(nibName: cellIdentidfier, bundle: nil), forCellWithReuseIdentifier: cellIdentidfier)
    }
}


//MARK: - Configure
extension ColorPickerCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorPicker.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let colorPickerCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentidfier, for: indexPath) as? ColorPickerCell {
            
            let color = colorPicker[indexPath.item].color
            colorPickerCell.configureCell(color: color.color, indexPath: indexPath.item, selectedIndexPath: selectedColor)
            
            return colorPickerCell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedColor = indexPath.item
        didSelectColor?(colorPicker[indexPath.item].color)
        reloadData()
    }
}
