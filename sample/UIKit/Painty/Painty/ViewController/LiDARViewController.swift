//
//  LiDARViewController.swift
//  iOS-AR-Remodel-Module-UIKit
//
//  Created by Nikunj on 03/12/21.
//

import UIKit
import ARKit
import RemodelAR

final class LiDARViewController: UIViewController {
    
    //MARK: @IBOutlets
    @IBOutlet weak private var arscnView: ARSCNView!
    @IBOutlet weak private var lidarButtonsStackView: UIStackView!
    @IBOutlet weak private var planerMeshesCountLabel: UILabel!
    @IBOutlet weak private var texturePickerCollectionView: TexturePickerCollectionView!
    @IBOutlet weak private var colorPickerCollectionView: ColorPickerCollectionView!
    
    //MARK: Properties
    private lazy var arController: ARController = {
        RemodelARLib.makeLidarARController(with: arscnView)
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        configureLiDARView()
        arController.startScene(reset: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        arController.pauseScene()
    }
}

//MARK: - Create and configure ARView
extension LiDARViewController {
    private func configureLiDARView() {
        if !ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            
            showAlert(title: "Unsupported Device", message: "Your device does not support LiDAR. Please use a device that supports LiDAR.")
            lidarButtonsStackView.isHidden = true
            planerMeshesCountLabel.isHidden = true
            
        } else {
            arController.planarMeshCountUpdated = { [weak self] meshCount in
                DispatchQueue.main.async {
                    self?.planerMeshesCountLabel.text = "Planar Meshes: \(meshCount)"
                }
            }
            
            texturePickerCollectionView.texturePicker = TexturePicker.textures
            texturePickerCollectionView.arController = arController
            
            colorPickerCollectionView.colorPicker = ColorPicker.colors
            colorPickerCollectionView.arController = arController
        }
    }
}

//MARK: - @IBActions
extension LiDARViewController {
    @IBAction func onSavePhotoTapped(_ sender: PaintyButton) {
        let savedImage = arController.savePhoto()
        UIImageWriteToSavedPhotosAlbum(savedImage, self, nil, nil)
    }
    
    @IBAction func onSave3DMeshTapped(_ sender: PaintyButton) {
        arController.save3DModel()
    }
    
    @IBAction func onResetTapped(_ sender: PaintyButton) {
        arController.resetScene()
    }
    
    @IBAction func onGetPaintInfoTapped(_ sender: PaintyButton) {
        let paintInfo = arController.retrievePaintInfo()
        print("Paint Info:- ,", paintInfo as Any)
    }
}

//MARK: - Touches
extension LiDARViewController {
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first
        else { return }
        
        let point = touch.location(in: arscnView)
        arController.handleTouch(point: point)
    }
}
