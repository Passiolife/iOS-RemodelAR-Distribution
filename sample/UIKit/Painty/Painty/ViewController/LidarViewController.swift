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
    @IBOutlet weak private var buttonsTopStackView: UIStackView!
    @IBOutlet weak private var buttonsBottomStackView: UIStackView!
    @IBOutlet weak private var planarMeshesCountLabel: UILabel!
    @IBOutlet private var touchModeButtons: [PaintyButton]!
    @IBOutlet weak private var texturePickerCollectionView: TexturePickerCollectionView!
    @IBOutlet weak private var colorPickerCollectionView: ColorPickerCollectionView!
    @IBOutlet weak var showUIButton: PaintyButton!
    
    //MARK: Properties
    private var arscnView: ARSCNView?
    private var arController: ARController?
    
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
            arController?.setScanMode(scanMode: scanMode)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        configureView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unconfigureView()
    }
}

//MARK: - Create and configure ARView
extension LidarViewController {
    private func configureView() {
        if !ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            showAlert(title: "Unsupported Device", message: "Your device does not support Lidar. Please use a device that supports Lidar.")
            buttonsTopStackView.isHidden = true
            buttonsBottomStackView.isHidden = true
            planarMeshesCountLabel.isHidden = true
            
        } else {
            createARView()
            configureBindings()
            arController?.startScene(reset: true)
        }
    }
    
    private func unconfigureView() {
        texturePickerCollectionView.arController = nil
        colorPickerCollectionView.arController = nil
        arController = nil
        arscnView?.removeFromSuperview()
        arscnView = nil
    }
    
    private func createARView() {
        addAndConfigureARViews()
        addGestureOnARView()

        texturePickerCollectionView.texturePicker = TexturePicker.textures
        texturePickerCollectionView.arController = arController

        colorPickerCollectionView.colorPicker = ColorPicker.colors
        colorPickerCollectionView.arController = arController
    }
    
    private func addAndConfigureARViews() {
        arscnView = ARSCNView()
        guard let arscnView = arscnView
        else { return }
        
        view.addSubview(arscnView)
        view.sendSubviewToBack(arscnView)
        arscnView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            arscnView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                               constant: 0),
            arscnView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                           constant: 0),
            arscnView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                constant: 0),
            arscnView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                              constant: 0)
        ])
        
        arController = RemodelARLib.makeLidarARController(with: arscnView)
    }
    
    private func configureBindings() {
        arController?.planarMeshCountUpdated = { [weak self] meshCount in
            DispatchQueue.main.async {
                self?.planarMeshesCountLabel.text = "Planar Meshes: \(meshCount)"
            }
        }
        arController?.cameraAimInfoUpdated = { cameraAimInfo in
            guard let cameraAimInfo = cameraAimInfo
            else { return }
            
            print("cameraAim: \(cameraAimInfo.angle), \(cameraAimInfo.surfaceType)")
        }
        arController?.wallPainted = {
            print("a wall was painted!")
        }
        arController?.trackingReady = { isReady in
            print("tracking ready: \(isReady ? "true" : "false")")
        }
    }
    
    private func addGestureOnARView() {
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(onDraggingARView(_:)))
        arscnView?.isUserInteractionEnabled = true
        arscnView?.addGestureRecognizer(dragGesture)
    }
    
    @objc private func onDraggingARView(_ sender: UIPanGestureRecognizer) {
        guard let arscnView = arscnView
        else { return }
        
        switch sender.state {
        case .changed:
            arController?.dragStart(point: sender.location(in: arscnView))
            arController?.dragMove(point: sender.location(in: arscnView))
            
        case .ended:
            arController?.dragEnd()
            
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
        arController?.setColorThreshold(threshold: sender.value)
    }
    
    @IBAction func onSavePhotoTapped(_ sender: PaintyButton) {
        unconfigureView()
        return
        
        guard let photo = arController?.savePhoto()
        else { return }
        
        let activityViewController = UIActivityViewController(activityItems: [photo],
                                                              applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func onSave3DMeshTapped(_ sender: PaintyButton) {
        arController?.save3DModel()
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
        arController?.resetScene()
    }
    
    @IBAction func onGetPaintInfoTapped(_ sender: PaintyButton) {
        let paintInfo = arController?.retrievePaintInfo()
        print("Paint Info:- ,", paintInfo as Any)
    }
    
    @IBAction func onToggleUITapped(_ sender: PaintyButton) {
        showUI.toggle()
    }
    
    @IBAction func showUITapped(_ sender: PaintyButton) {
        showUI = true
    }
    
    @IBAction func onColor1Tapped(_ sender: PaintyButton) {
        arController?.setTouchMode(mode: .color1)
        updateHighlightedButton(sender: sender)
    }
    
    @IBAction func onColor2Tapped(_ sender: PaintyButton) {
        arController?.setTouchMode(mode: .color2)
        updateHighlightedButton(sender: sender)
    }
    
    @IBAction func onColor3Tapped(_ sender: PaintyButton) {
        arController?.setTouchMode(mode: .color3)
        updateHighlightedButton(sender: sender)
    }
    
    @IBAction func onARPickerTapped(_ sender: PaintyButton) {
        arController?.setTouchMode(mode: .brightness)
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
        arController?.handleTouch(point: point)
    }
}
