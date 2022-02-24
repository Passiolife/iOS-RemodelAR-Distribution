//
//  LidarViewController.swift
//  Painty
//
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit
import ARKit
import RemodelAR

final class LidarViewController: UIViewController {
    
    //MARK: @IBOutlets
    @IBOutlet weak private var arscnView: ARSCNView!
    @IBOutlet weak private var buttonsTopStackView: UIStackView!
    @IBOutlet weak private var buttonsBottomStackView: UIStackView!
    @IBOutlet weak private var planerMeshesCountLabel: UILabel!
    @IBOutlet private var touchModeButtons: [PaintyButton]!
    @IBOutlet weak private var texturePickerCollectionView: TexturePickerCollectionView!
    @IBOutlet weak private var colorPickerCollectionView: ColorPickerCollectionView!
    @IBOutlet weak var showUIButton: PaintyButton!
    
    //MARK: Properties
    private lazy var arController: ARController = {
        RemodelARLib.makeLidarARController(with: arscnView)
    }()
    
    private var showUI = true {
        didSet {
            showUIButton.isHidden = showUI
            buttonsTopStackView.isHidden = !showUI
            buttonsBottomStackView.isHidden = !showUI
            tabBarController?.setTabBarHidden(!showUI, animated: true)
        }
    }
    
    private var isLidarScanning = true {
        didSet {
            let scanMode: ScanMode = isLidarScanning ? .scanning : .paused
            arController.setScanMode(scanMode: scanMode)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        configureLidarView()
        arController.startScene(reset: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        arController.pauseScene()
    }
}

//MARK: - Create and configure ARView
extension LidarViewController {
    private func configureLidarView() {
        if !ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            
            showAlert(title: "Unsupported Device", message: "Your device does not support Lidar. Please use a device that supports Lidar.")
            buttonsTopStackView.isHidden = true
            buttonsBottomStackView.isHidden = true
            planerMeshesCountLabel.isHidden = true
            
        } else {
            addGestureOnARView()
            
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
    
    private func addGestureOnARView() {
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(onDraggingARView(_:)))
        arscnView.isUserInteractionEnabled = true
        arscnView.addGestureRecognizer(dragGesture)
    }
    
    @objc private func onDraggingARView(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            arController.dragStart(point: sender.location(in: arscnView))
            arController.dragMove(point: sender.location(in: arscnView))
            
        case .ended:
            arController.dragEnd()
            
        default:
            break
        }
    }
    
    private func updateHighlightedButton(sender: PaintyButton) {
        touchModeButtons.forEach {
            $0.backgroundColor = ($0 == sender) ? .black.withAlphaComponent(0.5) : .black.withAlphaComponent(0.15)
        }
    }
}

//MARK: - @IBActions
extension LidarViewController {
    @IBAction func onThresholdSliderChanged(_ sender: UISlider) {
        arController.setColorThreshold(threshold: sender.value)
    }
    
    @IBAction func onSavePhotoTapped(_ sender: PaintyButton) {
        let photo = arController.savePhoto()
        let activityViewController = UIActivityViewController(activityItems: [photo],
                                                              applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func onSave3DMeshTapped(_ sender: PaintyButton) {
        arController.save3DModel()
        let filename = FileManager.documentsFolder.appendingPathComponent("Mesh.usdz")
        if FileManager.default.fileExists(atPath: filename.path) {
            let activityViewController = UIActivityViewController(
                activityItems: [filename],
                applicationActivities: nil
            )
            present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func onResetTapped(_ sender: PaintyButton) {
        arController.resetScene()
    }
    
    @IBAction func onGetPaintInfoTapped(_ sender: PaintyButton) {
        let paintInfo = arController.retrievePaintInfo()
        print("Paint Info:- ,", paintInfo as Any)
    }
    
    @IBAction func onToggleUITapped(_ sender: PaintyButton) {
        showUI.toggle()
    }
    
    @IBAction func showUITapped(_ sender: PaintyButton) {
        showUI = true
    }
    
    @IBAction func onColor1Tapped(_ sender: PaintyButton) {
        arController.setTouchMode(mode: .lightColor)
        updateHighlightedButton(sender: sender)
    }
    
    @IBAction func onColor2Tapped(_ sender: PaintyButton) {
        arController.setTouchMode(mode: .averageColor)
        updateHighlightedButton(sender: sender)
    }
    
    @IBAction func onColor3Tapped(_ sender: PaintyButton) {
        arController.setTouchMode(mode: .darkColor)
        updateHighlightedButton(sender: sender)
    }
    
    @IBAction func onARPickerTapped(_ sender: PaintyButton) {
        arController.setTouchMode(mode: .brightness)
        updateHighlightedButton(sender: sender)
    }
    
    @IBAction func onPauseLidarTapped(_ sender: PaintyButton) {
        isLidarScanning.toggle()
    }
}

//MARK: - Touches
extension LidarViewController {
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first
        else { return }
        
        let point = touch.location(in: arscnView)
        arController.handleTouch(point: point)
    }
}
