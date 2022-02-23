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
    @IBOutlet private var touchModeButtons: [PaintyButton]!
    
    //MARK: Properties
    private lazy var arController: ARController = {
        RemodelARLib.makeShaderARController(with: arscnView)
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
extension ShaderPaintViewController {
    private func configureUI() {
        createARView()
        
        thresoldSlider.value = 10
    }
}

//MARK: - Create and configure ARView
extension ShaderPaintViewController {
    private func createARView() {
        addGestureOnARView()
        
        arController.setColor(paint: ColorPicker.colors[0].color)
        
        // ["Average", "Dark", "Light", "Brightness"]
        arController.setTouchMode(mode: TouchMode(rawValue: 3)!)
        
        colorPickerCollectionView.colorPicker = ColorPicker.colors
        colorPickerCollectionView.arController = arController
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
    
    @IBAction func onTouchModeButtonsTapped(_ sender: PaintyButton) {
        touchModeButtons.forEach {
            $0.backgroundColor = ($0 == sender) ? .black : .black.withAlphaComponent(0.5)
        }
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
