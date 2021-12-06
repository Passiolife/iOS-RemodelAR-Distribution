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
    private var arController: ARController?
    
    //MARK: View Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        arController?.startScene()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        arController?.pauseScene()
    }
}

//MARK: - Configure UI
extension LegacyViewController {
    
    private func configureUI() {
        
        createARView()
        
        drawCenterPoint(rect: CGRect(x: view.frame.width/2 - 30,
                                     y: view.frame.height/2 - 30,
                                     width: 60, height: 60),
                        lineWidth: 2, fillColor: false)
        
        drawCenterPoint(rect: CGRect(x: view.frame.width/2 - 8,
                                     y: view.frame.height/2 - 8,
                                     width: 16, height: 16),
                        lineWidth: 1, fillColor: true)
        
        updateARLabelStatus()
    }
}

//MARK: - Create and configure ARView
extension LegacyViewController {
    
    private func createARView() {
        
        arController = RemodelARLib.makeLegacyARController(with: arscnView)
        
        addGestureOnARView()
        
        arController?.setScanPoint(point: view.center)
        arController?.setColor(paint: colorPicker[0].color)
        
        colorPickerCollectionView.colorPicker = colorPicker
        colorPickerCollectionView.arController = arController
        
        texturePickerCollectionView.texturePicker = texturePicker
        texturePickerCollectionView.arController = arController
    }
    
    private func drawCenterPoint(rect: CGRect, lineWidth: CGFloat, fillColor: Bool) {
        
        let circleLayer = CAShapeLayer()
        
        circleLayer.path = UIBezierPath(ovalIn: rect).cgPath
        
        circleLayer.fillColor = fillColor ? UIColor.systemBlue.cgColor : UIColor.black.withAlphaComponent(0.25).cgColor
        circleLayer.strokeColor = UIColor.systemBlue.cgColor
        circleLayer.lineWidth = lineWidth
        
        view.layer.addSublayer(circleLayer)
    }
    
    private func addGestureOnARView() {
        
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(onDraggingARView(_:)))
        arscnView.isUserInteractionEnabled = true
        arscnView.addGestureRecognizer(dragGesture)
    }
    
    @objc private func onDraggingARView(_ sender: UIPanGestureRecognizer) {
        
        let gestureState = sender.state
        
        switch gestureState {
            
        case .changed:
            arController?.dragStart(point: sender.location(in: arscnView))
            arController?.dragMove(point: sender.location(in: arscnView))
            
        case .ended:
            arController?.dragEnd()
            
        default:
            break
        }
    }
    
    private func updateARLabelStatus() {
        
        arController?.trackingReady = { [weak self] isReadyForTracknig in
            self?.trackingLabel.text = "Tracking Ready: \(isReadyForTracknig ? "On" : "Off")"
        }
        
        arController?.wallStateUpdated = { [weak self] wallState in
            
            switch wallState {
                
            case .idle:
                self?.wallStateLabel.text = "Wall state: Idle"
                
            case .addingWall:
                self?.wallStateLabel.text = "Wall state: Adding wall"
                
            @unknown default:
                break
            }
        }
        
        arController?.placeWallStateUpdated = { [weak self] placeWallState in
            
            switch placeWallState {
                
            case .placingBasePlane:
                self?.placeWallStateLabel.text = "Place wall state: Placing base plane"
                
            case .placingUpperLeftCorner:
                self?.placeWallStateLabel.text = "Place wall state: Placing upper left corner"
                
            case .placingBottomRightCorner:
                self?.placeWallStateLabel.text = "Place wall state: Placing bottom right corner"
                
            case .done:
                self?.placeWallStateLabel.text = "Place wall state: Done"
                
            @unknown default:
                break
            }
        }
    }
}

//MARK: - IBActions
extension LegacyViewController {
    
    @IBAction func onSetLRTapped(_ sender: UIButton) {
        arController?.setLowerRightCorner()
    }
    
    @IBAction func onSetULTapped(_ sender: UIButton) {
        arController?.setUpperLeftCorner()
    }
    
    @IBAction func onUpdatePlaneTapped(_ sender: UIButton) {
        arController?.updateWallBasePlane()
    }
    
    @IBAction func onPlacePlaneTapped(_ sender: UIButton) {
        arController?.placeWallBasePlane()
    }
    
    @IBAction func onAddWallTapped(_ sender: UIButton) {
        arController?.addWall()
    }
    
    @IBAction func onCancelTapped(_ sender: UIButton) {
        arController?.endAddWall()
    }
    
    @IBAction func onResetTapped(_ sender: UIButton) {
        arController?.resetScene()
    }
}
