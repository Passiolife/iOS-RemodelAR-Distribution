//
//  TexturePickerCollectionView.swift
//  Painty
//
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit
import RemodelAR

final class TexturePickerCollectionView: UICollectionView {
    
    var texturePicker = [TexturePicker]() {
        didSet {
            reloadData()
        }
    }
    
    var arController: ARController?
    
    private let cellIdentidfier = "TexturePickerCell"
    
    private var selectedTexture = -1
    private var showTexture = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
    }
}

//MARK: - Configure
extension TexturePickerCollectionView {
    
    private func configure() {
        
        delegate = self
        dataSource = self
        register(UINib(nibName: cellIdentidfier, bundle: nil), forCellWithReuseIdentifier: cellIdentidfier)
    }
}


//MARK: - Configure
extension TexturePickerCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return texturePicker.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let texturePickerCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentidfier, for: indexPath) as? TexturePickerCell {
            
            let texture = texturePicker[indexPath.item].texture
            texturePickerCell.configureCell(texture: texture, indexPath: indexPath.item, selectedIndexPath: selectedTexture, showTexture: showTexture)
            
            return texturePickerCell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == selectedTexture {
            
            arController?.setTexture(texture: nil)
            selectedTexture = -1
            showTexture = false
            
        } else {
            showTexture = true
            selectedTexture = indexPath.item
            arController?.setTexture(texture: UIImage(named: texturePicker[indexPath.item].texture))
        }
        reloadData()
    }
}
