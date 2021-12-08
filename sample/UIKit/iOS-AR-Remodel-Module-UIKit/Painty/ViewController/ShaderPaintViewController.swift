//
//  ShaderPaintViewController.swift
//  iOS-AR-Remodel-Module-UIKit
//
//  Created by Nikunj on 03/12/21.
//

import UIKit
import RemodelAR
import ARKit

final class ShaderPaintViewController: UIViewController {
    
    //MARK: @IBOutlets
    @IBOutlet weak private var arscnView: ARSCNView!
    @IBOutlet weak private var colorPickerCollectionView: ColorPickerCollectionView!
    @IBOutlet weak private var thresoldSlider: UISlider!
    @IBOutlet private var abTestbuttons: [PaintyButton]!
    @IBOutlet private var touchModeButtons: [PaintyButton]!
    
    //MARK: Properties
    private lazy var arController: ARController = {
        return RemodelARLib.makeLidarARController(with: arscnView)
    }()
    
    private var abModeIndex = 0 {
        didSet {
            showCenterPoint(index: abModeIndex)
        }
    }
    
    private var outerCenterPoint = CenterPoint()
    private var innerCenterPoint = CenterPoint()
    
    private var isCenterPointAdded = false
    
    //MARK: View Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        arController.startScene()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        arController.pauseScene()
    }
}

//MARK: - Configure UI
extension ShaderPaintViewController {
    
    private func configureUI() {
        
        createARView()
        
        thresoldSlider.value = 10
    }
}

//MARK: - Create and configure ARView
extension ShaderPaintViewController {
    
    private func createARView() {
        
        arController = RemodelARLib.makeShaderARController(with: arscnView)
        
        addGestureOnARView()
        
        arController.setColor(paint: colorPicker[0].color)
        arController.setTouchMode(mode: TouchMode(rawValue: 3)!) //["Average", "Dark", "Light", "Brightness"]
        
        colorPickerCollectionView.colorPicker = colorPicker
        colorPickerCollectionView.arController = arController
        
        createCenterPoint()
        abModeIndex = 2
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
            arController.dragStart(point: sender.location(in: arscnView))
            arController.dragMove(point: sender.location(in: arscnView))
            
        case .ended:
            arController.dragEnd()
            
        default:
            break
        }
    }
    
    private func createCenterPoint() {
        
        outerCenterPoint = CenterPoint(frame: CGRect(x: view.frame.width/2 - 30, y: view.frame.height/2 - 30, width: 60, height: 60))
        innerCenterPoint = CenterPoint(frame: CGRect(x: view.frame.width/2 - 8, y: view.frame.height/2 - 8, width: 16, height: 16))
        
        view.addSubview(outerCenterPoint)
        view.addSubview(innerCenterPoint)
    }
    
    private func showCenterPoint(index: Int) {
        
        outerCenterPoint.isHidden = index == 0 ? false : true
        innerCenterPoint.isHidden = index == 0 ? false : true
    }
}

//MARK: - @IBActions
extension ShaderPaintViewController {
    
    @IBAction func onThresoldSliderChanged(_ sender: UISlider) {
        arController.setColorThreshold(threshold: sender.value)
    }
    
    @IBAction func onSaveToCameraTapped(_ sender: PaintyButton) {
        
        let savedImage = arController.savePhoto()
        UIImageWriteToSavedPhotosAlbum(savedImage, self, nil, nil)
    }
    
    @IBAction func onRecordTapped(_ sender: PaintyButton) {
        
        arController.setABTestingMode(mode: 0) //["Record", "Stop", "Idle"]
        abModeIndex = 0
    }
    
    @IBAction func onStopTapped(_ sender: PaintyButton) {
        arController.setABTestingMode(mode: 1) //["Record", "Stop", "Idle"]
        abModeIndex = 1
    }
    
    @IBAction func onIdleTapped(_ sender: PaintyButton) {
        arController.setABTestingMode(mode: 2) //["Record", "Stop", "Idle"]
        abModeIndex = 2
    }
    
    @IBAction func onAverageTapped(_ sender: PaintyButton) {
        arController.setTouchMode(mode: TouchMode(rawValue: 0)!)
    }
    
    @IBAction func onDarkTapped(_ sender: PaintyButton) {
        arController.setTouchMode(mode: TouchMode(rawValue: 1)!)
    }
    
    @IBAction func onLightTapped(_ sender: PaintyButton) {
        arController.setTouchMode(mode: TouchMode(rawValue: 2)!)
    }
    
    @IBAction func onBrightnessTapped(_ sender: PaintyButton) {
        arController.setTouchMode(mode: TouchMode(rawValue: 3)!)
    }
    
    @IBAction func onResetTapped(_ sender: PaintyButton) {
        arController.resetScene()
    }
    
    @IBAction func onABTestModeTapped(_ sender: PaintyButton) {
        abTestbuttons.forEach { $0.backgroundColor = ($0 == sender) ? .black : .black.withAlphaComponent(0.5) }
    }
    
    @IBAction func onTouchModeButtonsTapped(_ sender: PaintyButton) {
        touchModeButtons.forEach { $0.backgroundColor = ($0 == sender) ? .black : .black.withAlphaComponent(0.5) }
    }
}

//MARK: - Touches
extension ShaderPaintViewController {
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first
        else { return }
        
        let point = touch.location(in: arscnView)
        arController.handleTouch(point: point)
    }
}
