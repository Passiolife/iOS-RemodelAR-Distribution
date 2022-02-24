//
//  AbnormalitiesViewController.swift
//  Painty
//
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit
import ARKit
import RemodelAR

final class AbnormalitiesViewController: UIViewController {
    
    //MARK: @IBOutlets
    @IBOutlet weak private var arscnView: ARSCNView!
    @IBOutlet weak private var buttonsTopStackView: UIStackView!
    @IBOutlet weak private var buttonsBottomStackView: UIStackView!
    @IBOutlet weak var showUIButton: PaintyButton!
    
    //MARK: Properties
    private lazy var arController: ARController = {
        RemodelARLib.makeAbnormalitiesARController(with: arscnView)
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
        
        configureView()
        arController.startScene(reset: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        arController.pauseScene()
    }
}

//MARK: - Create and configure ARView
extension AbnormalitiesViewController {
    private func configureView() {
        if !ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            
            showAlert(title: "Unsupported Device", message: "Your device does not support Lidar. Please use a device that supports Lidar.")
            buttonsTopStackView.isHidden = true
            buttonsBottomStackView.isHidden = true
            
        }
    }
}

//MARK: - @IBActions
extension AbnormalitiesViewController {
    @IBAction func onSavePhotoTapped(_ sender: PaintyButton) {
        let photo = arController.savePhoto()
        let activityViewController = UIActivityViewController(activityItems: [photo],
                                                              applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func onResetTapped(_ sender: PaintyButton) {
        arController.resetScene()
    }
    
    @IBAction func onAddDefectTapped(_ sender: PaintyButton) {
        _ = arController.addAbnormality(name: "Crack")
    }
    
    @IBAction func onRetrieveDefectsTapped(_ sender: PaintyButton) {
        guard let defectsInfo = arController.retrieveAbnormalitiesInfo()
        else { return }
        
        print("Defects:")
        for defect in defectsInfo.abnormalities {
            print("\(defect.name): \(defect.area.width)x\(defect.area.height)")
        }
    }
    
    @IBAction func onToggleUITapped(_ sender: PaintyButton) {
        showUI.toggle()
    }
    
    @IBAction func showUITapped(_ sender: PaintyButton) {
        showUI = true
    }
    
    @IBAction func onPauseLidarTapped(_ sender: PaintyButton) {
        isLidarScanning.toggle()
    }
}

//MARK: - Touches
extension AbnormalitiesViewController {
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first
        else { return }
        
        let point = touch.location(in: arscnView)
        arController.handleTouch(point: point)
    }
}
