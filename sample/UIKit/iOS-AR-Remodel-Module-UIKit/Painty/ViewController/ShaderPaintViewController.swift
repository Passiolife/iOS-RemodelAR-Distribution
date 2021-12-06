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
    @IBOutlet weak var colorPickerCollectionView: ColorPickerCollectionView!
    @IBOutlet weak var thresoldSlider: UISlider!
    @IBOutlet weak var arscnView: ARSCNView!
    
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
extension ShaderPaintViewController {
    
    private func configureUI() {
        
        createARView()
    }
}

//MARK: - Create and configure ARView
extension ShaderPaintViewController {
    
    private func createARView() {
        
        arController = RemodelARLib.makeShaderARController(with: arscnView)
        
        addGestureOnARView()
        
        arController?.setColor(paint: colorPicker[0].color)
        arController?.setTouchMode(mode: TouchMode(rawValue: 3)!) //["Average", "Dark", "Light", "Brightness"]
        
        colorPickerCollectionView.colorPicker = colorPicker
        colorPickerCollectionView.arController = arController
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
}

//MARK: - @IBActions
extension ShaderPaintViewController {
    
    @IBAction func onThresoldSliderChanged(_ sender: UISlider) {
        arController?.setColorThreshold(threshold: sender.value)
    }
    
    @IBAction func onSaveToCameraTapped(_ sender: PaintyButton) {
        
        guard let savedImage = arController?.savePhoto() else { return }
        UIImageWriteToSavedPhotosAlbum(savedImage, self, nil, nil)
    }
    
    @IBAction func onRecordTapped(_ sender: PaintyButton) {
        arController?.setABTestingMode(mode: 0) //["Record", "Stop", "Idle"]
    }
    
    @IBAction func onStopTapped(_ sender: PaintyButton) {
        arController?.setABTestingMode(mode: 1) //["Record", "Stop", "Idle"]
    }
    
    @IBAction func onIdleTapped(_ sender: PaintyButton) {
        arController?.setABTestingMode(mode: 2) //["Record", "Stop", "Idle"]
    }
    
    @IBAction func onAverageTapped(_ sender: PaintyButton) {
        arController?.setTouchMode(mode: TouchMode(rawValue: 0)!)
    }
    
    @IBAction func onDarkTapped(_ sender: PaintyButton) {
        arController?.setTouchMode(mode: TouchMode(rawValue: 1)!)
    }
    
    @IBAction func onLightTapped(_ sender: PaintyButton) {
        arController?.setTouchMode(mode: TouchMode(rawValue: 2)!)
    }
    
    @IBAction func onBrightnessTapped(_ sender: PaintyButton) {
        arController?.setTouchMode(mode: TouchMode(rawValue: 3)!)
    }
    
    @IBAction func onResetTapped(_ sender: PaintyButton) {
        arController?.resetScene()
    }
}
