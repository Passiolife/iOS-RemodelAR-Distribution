//
//  LegacyViewController.swift
//  Painty
//
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit
import ARKit
import RemodelAR

final class LegacyViewController: UIViewController {
    
    //MARK: @IBOutlets
    @IBOutlet weak private var arscnView: ARSCNView!
    @IBOutlet weak private var buttonsTopStackView: UIStackView!
    @IBOutlet weak private var buttonsBottomStackView: UIStackView!
    @IBOutlet weak private var placeWallStateLabel: UILabel!
    @IBOutlet weak private var wallStateLabel: UILabel!
    @IBOutlet weak private var trackingLabel: UILabel!
    @IBOutlet private var touchModeButtons: [PaintyButton]!
    @IBOutlet weak private var colorPickerCollectionView: ColorPickerCollectionView!
    @IBOutlet weak private var texturePickerCollectionView: TexturePickerCollectionView!
    @IBOutlet weak var showUIButton: PaintyButton!
    
    //MARK: Properties
    private lazy var arController: ARController = {
        RemodelARLib.makeLegacyARController(with: arscnView)
    }()
    
    private var showUI = true {
        didSet {
            showUIButton.isHidden = showUI
            buttonsTopStackView.isHidden = !showUI
            buttonsBottomStackView.isHidden = !showUI
            tabBarController?.setTabBarHidden(!showUI, animated: true)
        }
    }
    
    //MARK: View Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        arController.startScene(reset: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        arController.pauseScene()
    }
}

//MARK: - Configure UI
extension LegacyViewController {
    private func configureUI() {
        createARView()
        updateARLabelStatus()
    }
}

//MARK: - Create and configure ARView
extension LegacyViewController {
    private func createARView() {
        addGestureOnARView()
        
        arController.setColor(paint: ColorPicker.colors[0].color)
        
        colorPickerCollectionView.colorPicker = ColorPicker.colors
        colorPickerCollectionView.arController = arController
        
        texturePickerCollectionView.texturePicker = TexturePicker.textures
        texturePickerCollectionView.arController = arController
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
    
    private func updateARLabelStatus() {
        arController.trackingReady = { [weak self] isReadyForTracking in
            DispatchQueue.main.async {
                self?.trackingLabel.text = "Tracking Ready: \(isReadyForTracking ? "On" : "Off")"
            }
        }
        
        arController.wallStateUpdated = { [weak self] wallState in
            DispatchQueue.main.async {
                switch wallState {
                case .idle:
                    self?.wallStateLabel.text = "Wall state: Idle"
                    
                case .addingWall:
                    self?.wallStateLabel.text = "Wall state: Adding wall"
                    
                @unknown default:
                    break
                }
            }
        }
        
        arController.placeWallStateUpdated = { [weak self] placeWallState in
            DispatchQueue.main.async {
                switch placeWallState {
                case .placingBasePlane:
                    self?.placeWallStateLabel.text = "Place wall state: Placing base plane"
                    
                case .placingFirstCorner:
                    self?.placeWallStateLabel.text = "Place wall state: Placing first corner"
                    
                case .placingSecondCorner:
                    self?.placeWallStateLabel.text = "Place wall state: Placing second corner"
                    
                case .done:
                    self?.placeWallStateLabel.text = "Place wall state: Done"
                    
                @unknown default:
                    break
                }
            }
        }
    }
    
    private func updateHighlightedButton(sender: PaintyButton) {
        touchModeButtons.forEach {
            $0.backgroundColor = ($0 == sender) ? .black.withAlphaComponent(0.5) : .black.withAlphaComponent(0.15)
        }
    }
}

//MARK: - IBActions
extension LegacyViewController {
    @IBAction func onThresholdSliderChanged(_ sender: UISlider) {
        arController.setColorThreshold(threshold: sender.value)
    }
    
    @IBAction func onSetFirstPointTapped(_ sender: UIButton) {
        arController.setSecondCorner()
    }
    
    @IBAction func onSetSecondPointTapped(_ sender: UIButton) {
        arController.setFirstCorner()
    }
    
    @IBAction func onUpdatePlaneTapped(_ sender: UIButton) {
        arController.updateWallBasePlane()
    }
    
    @IBAction func onPlacePlaneTapped(_ sender: UIButton) {
        arController.placeWallBasePlane()
    }
    
    @IBAction func onCancelTapped(_ sender: UIButton) {
        arController.endAddWall()
    }
    
    @IBAction func onResetTapped(_ sender: UIButton) {
        arController.resetScene()
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
    
    @IBAction func onSavePhotoTapped(_ sender: PaintyButton) {
        let photo = arController.savePhoto()
        let activityViewController = UIActivityViewController(activityItems: [photo],
                                                              applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func onGetPaintInfoTapped(_ sender: PaintyButton) {
        let paintInfo = arController.retrievePaintInfo()
        print("Paint Info:- ,", paintInfo as Any)
    }
}

//MARK: - Touches

extension LegacyViewController {
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first
        else { return }
        
        let point = touch.location(in: arscnView)
        arController.handleTouch(point: point)
    }
}
