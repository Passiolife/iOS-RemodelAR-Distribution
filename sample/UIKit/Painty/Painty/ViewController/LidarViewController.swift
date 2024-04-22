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
    @IBOutlet weak var scanButton: PaintyButton!
    
    //MARK: Properties
    private var arscnView: ARSCNView?
    private var arController: ARController?
    
    private var activeColor: WallPaint = ColorPicker.colors[0].color {
        didSet {
            arController?.setColor(paint: activeColor, texture: activeTexture)
        }
    }
    
    private var activeTexture: UIImage? {
        didSet {
            arController?.setColor(paint: activeColor, texture: activeTexture)
        }
    }
    
    private var showUI = true {
        didSet {
            showUIButton.isHidden = showUI
            buttonsTopStackView.isHidden = !showUI
            buttonsBottomStackView.isHidden = !showUI
            tabBarController?.setTabBarHidden(!showUI, animated: true)
        }
    }
    
    private var isLidarScanning = false {
        didSet {
            let scanMode: ScanMode = isLidarScanning ? .scanning : .paused
            if scanMode == .scanning {
                scanButton.setTitle("Stop Scan", for: .normal)
                arController?.startLidarScan()
            } else {
                scanButton.setTitle("Start Scan", for: .normal)
                arController?.stopLidarScan()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        arController = nil
        arscnView?.removeFromSuperview()
        arscnView = nil
    }
    
    private func createARView() {
        addAndConfigureARViews()
        addGestureOnARView()

        arController?.setColor(paint: ColorPicker.colors[0].color)
        
        colorPickerCollectionView.colorPicker = ColorPicker.colors
        colorPickerCollectionView.didSelectColor = { [weak self] color in
            self?.activeColor = color
        }
        
        texturePickerCollectionView.texturePicker = TexturePicker.textures
        texturePickerCollectionView.didSelectTexture = { [weak self] texture in
            self?.activeTexture = texture
        }
    }
    
    private func addAndConfigureARViews() {
        arscnView = ARSCNView()
        guard let arscnView = arscnView
        else { return }
        
        view.addSubview(arscnView)
        view.sendSubviewToBack(arscnView)
        arscnView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            arscnView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            arscnView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            arscnView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            arscnView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
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
            
//            print("cameraAim: \(cameraAimInfo.angle), \(cameraAimInfo.surfaceType)")
        }
        arController?.wallPainted = {
            print("a wall was painted!")
        }
        arController?.trackingReady = { isReady in
            print("tracking ready: \(isReady ? "true" : "false")")
        }
        arController?.retrievedPaintInfo = { paintInfo in
            print("Paint Info:")
            for wall in paintInfo.paintedWalls {
                print("\(wall.id): \(wall.area.width)x\(wall.area.height), \(wall.paint.color.printUInt)")
            }
        }
    }
    
    private func addGestureOnARView() {
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(onDraggingARView(_:)))
        arscnView?.isUserInteractionEnabled = true
        arscnView?.addGestureRecognizer(dragGesture)
    }
    
    @objc private func onDraggingARView(_ sender: UIPanGestureRecognizer) {
        let point = sender.location(in: arscnView)
        
        switch sender.state {
        case .changed:
            arController?.dragStart(point: point)
            arController?.dragMove(point: point)
            
        case .ended:
            arController?.dragEnd(point: point)
            
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
        arController?.hideOutlineState()
        
        guard let photo = arController?.savePhoto()
        else { return }
        
        arController?.restoreOutlineState()
        
        let activityViewController = UIActivityViewController(activityItems: [photo],
                                                              applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func onSave3DMeshTapped(_ sender: PaintyButton) {
        arController?.save3DModel(callback: { [weak self] fileUrl in
            guard let self = self
            else { return }
            
            let filename = FileManager.documentsFolder.appendingPathComponent("Mesh.usdz")
            if FileManager.default.fileExists(atPath: filename.path) {
                let activityViewController = UIActivityViewController(
                    activityItems: [filename],
                    applicationActivities: nil
                )
                present(activityViewController, animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func onResetTapped(_ sender: PaintyButton) {
        arController?.resetScene()
    }
    
    @IBAction func onGetPaintInfoTapped(_ sender: PaintyButton) {
        arController?.retrievePaintInfo()
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
