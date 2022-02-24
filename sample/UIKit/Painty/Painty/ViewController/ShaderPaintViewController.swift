//
//  ShaderPaintViewController.swift
//  Painty
//
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit
import RemodelAR
import ARKit

final class ShaderPaintViewController: UIViewController {
    
    //MARK: @IBOutlets
    @IBOutlet weak private var arscnView: ARSCNView!
    @IBOutlet weak private var buttonsTopStackView: UIStackView!
    @IBOutlet weak private var buttonsBottomStackView: UIStackView!
    @IBOutlet weak private var colorPickerCollectionView: ColorPickerCollectionView!
    @IBOutlet weak private var thresoldSlider: UISlider!
    @IBOutlet private var touchModeButtons: [PaintyButton]!
    @IBOutlet weak var showUIButton: PaintyButton!
    
    //MARK: Properties
    private lazy var arController: ARController = {
        RemodelARLib.makeShaderARController(with: arscnView)
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
    
    private func updateHighlightedButton(sender: PaintyButton) {
        touchModeButtons.forEach {
            $0.backgroundColor = ($0 == sender) ? .black.withAlphaComponent(0.5) : .black.withAlphaComponent(0.15)
        }
    }
}

//MARK: - @IBActions
extension ShaderPaintViewController {
    @IBAction func onThresholdSliderChanged(_ sender: UISlider) {
        arController.setColorThreshold(threshold: sender.value)
    }
    
    @IBAction func onSaveToCameraTapped(_ sender: PaintyButton) {
        let photo = arController.savePhoto()
        let activityViewController = UIActivityViewController(activityItems: [photo],
                                                              applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
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
    
    @IBAction func onResetTapped(_ sender: PaintyButton) {
        arController.resetScene()
    }
    
    @IBAction func onToggleUITapped(_ sender: PaintyButton) {
        showUI.toggle()
    }
    
    @IBAction func showUITapped(_ sender: PaintyButton) {
        showUI = true
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