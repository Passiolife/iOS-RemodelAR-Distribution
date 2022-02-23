//
//  LegacyViewController.swift
//  iOS-AR-Remodel-Module-UIKit
//
//  Created by Nikunj on 03/12/21.
//

import UIKit
import ARKit
import RemodelAR

final class LegacyViewController: UIViewController {
    
    //MARK: @IBOutlets
    @IBOutlet weak private var arscnView: ARSCNView!
    @IBOutlet weak private var placeWallStateLabel: UILabel!
    @IBOutlet weak private var wallStateLabel: UILabel!
    @IBOutlet weak private var trackingLabel: UILabel!
    @IBOutlet weak private var colorPickerCollectionView: ColorPickerCollectionView!
    @IBOutlet weak private var texturePickerCollectionView: TexturePickerCollectionView!
    
    //MARK: Properties
    private lazy var arController: ARController = {
        RemodelARLib.makeLegacyARController(with: arscnView)
    }()
    
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
}

//MARK: - IBActions
extension LegacyViewController {
    @IBAction func onSetLRTapped(_ sender: UIButton) {
        arController.setSecondCorner()
    }
    
    @IBAction func onSetULTapped(_ sender: UIButton) {
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
