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
    private var arController: ARController?
    
    //MARK: View Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        configureLiDARView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        arController?.pauseScene()
    }
}

//MARK: - Configure UI
extension LiDARViewController {
    
    private func configureUI() {
        
        createARView()
    }
}

//MARK: - Create and configure ARView
extension LiDARViewController {
    
    private func createARView() {
        
        arController = RemodelARLib.makeLidarARController(with: arscnView)
    }
    
    private func configureLiDARView() {
        
        if !ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            
            showAlert(title: "Oops", message: "Your device does not support LiDAR scanner. Please use device that supports LiDAR scanner.")
            //lidarButtonsStackView.isHidden = true
            //planerMeshesCountLabel.isHidden = true
            
        } else {
            
        }
        
        arController?.planarMeshCountUpdated = { [weak self] meshCount in
            self?.planerMeshesCountLabel.text = "Planer Meshes: \(meshCount)"
        }
        
        texturePickerCollectionView.texturePicker = texturePicker
        texturePickerCollectionView.arController = arController
        
        colorPickerCollectionView.colorPicker = colorPicker
        colorPickerCollectionView.arController = arController
    }
}

//MARK: - @IBActions
extension LiDARViewController {
    
    @IBAction func onSavePhotoTapped(_ sender: PaintyButton) {
        
        guard let savedImage = arController?.savePhoto() else { return }
        UIImageWriteToSavedPhotosAlbum(savedImage, self, nil, nil)
    }
    
    @IBAction func onSave3DMeshTapped(_ sender: PaintyButton) {
        arController?.save3DModel()
    }
    
    @IBAction func onResetTapped(_ sender: PaintyButton) {
        arController?.resetScene()
    }
    
    @IBAction func onGetPaintInfoTapped(_ sender: PaintyButton) {
        
        let paintInfo = arController?.retrievePaintInfo()
        
        print("Paint Info:- ,", paintInfo as Any)
    }
}