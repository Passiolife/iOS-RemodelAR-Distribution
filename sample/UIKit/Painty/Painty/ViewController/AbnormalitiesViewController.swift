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
    @IBOutlet weak private var buttonsTopStackView: UIStackView!
    @IBOutlet weak private var buttonsBottomStackView: UIStackView!
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
extension AbnormalitiesViewController {
    private func configureView() {
        if !ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            
            showAlert(title: "Unsupported Device", message: "Your device does not support Lidar. Please use a device that supports Lidar.")
            buttonsTopStackView.isHidden = true
            buttonsBottomStackView.isHidden = true
            
        } else {
            addAndConfigureARViews()
            configureBindings()
            arController?.startScene(reset: true)
        }
    }
    
    private func unconfigureView() {
        arController = nil
        arscnView?.removeFromSuperview()
        arscnView = nil
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
        
        arController = RemodelARLib.makeAbnormalitiesARController(with: arscnView)
        
        let viewSize = view.frame.size
        let width: CGFloat = viewSize.width * 2 / 3
        let paddingX: CGFloat = (viewSize.width - width) / 2
        let paddingY: CGFloat = (viewSize.height - width) / 2
        let cropRect = CGRect(x: paddingX,
                              y: paddingY,
                              width: width,
                              height: width)
        arController?.setScanArea(rect: cropRect)
    }
    
    private func configureBindings() {
        arController?.cameraAimInfoUpdated = { cameraAimInfo in
            guard let cameraAimInfo = cameraAimInfo
            else { return }
            
//            print("Camera Aim: \(cameraAimInfo.angle), \(cameraAimInfo.surfaceType)")
        }
        arController?.trackingReady = { isReady in
            print("Tracking Ready: \(isReady ? "true" : "false")")
        }
        arController?.abnormalitySelected = { [weak self] abnormality in
            print("Selected Defect: \(abnormality.identifier)")
            let newDefect = AbnormalityInfo(identifier: abnormality.identifier, name: "New Crack")
            self?.arController?.updateAbnormality(abnormality: newDefect)
        }
    }
}

//MARK: - @IBActions
extension AbnormalitiesViewController {
    @IBAction func onSavePhotoTapped(_ sender: PaintyButton) {
        guard let photo = arController?.savePhoto()
        else { return }
        
        let activityViewController = UIActivityViewController(activityItems: [photo],
                                                              applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func onResetTapped(_ sender: PaintyButton) {
        arController?.resetScene()
    }
    
    @IBAction func onAddDefectTapped(_ sender: PaintyButton) {
        arController?.captureAbnormalityImage(callback: { [weak self] image in
            // process image here using ML libraries
            print("image captured: \(image.width)x\(image.height)")
            
            if let addedDefectId = self?.arController?.addAbnormality(name: "Crack") {
                print("Added defect: \(addedDefectId)")
            } else {
                print("Defect not added, error")
            }
        })
    }
    
    @IBAction func onRetrieveDefectsTapped(_ sender: PaintyButton) {
        guard let defectsInfo = arController?.retrieveAbnormalitiesInfo()
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
        arController?.handleTouch(point: point)
    }
}
