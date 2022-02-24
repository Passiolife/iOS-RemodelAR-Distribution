//
//  FloorplanViewController.swift
//  Painty
//
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit
import ARKit
import RemodelAR

final class FloorplanViewController: UIViewController {
    
    //MARK: @IBOutlets
    @IBOutlet weak private var trackingLabel: UILabel!
    @IBOutlet weak private var colorPickerCollectionView: ColorPickerCollectionView!
    @IBOutlet weak private var texturePickerCollectionView: TexturePickerCollectionView!
    @IBOutlet private var touchModeButtons: [PaintyButton]!
    @IBOutlet weak var showUnpaintedWallsButton: PaintyButton!
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
    
    private var showUnpaintedWalls = true {
        didSet {
            if showUnpaintedWalls {
                showUnpaintedWallsButton.setImage(UIImage(systemName: "eye"),
                                                  for: .normal)
            } else {
                showUnpaintedWallsButton.setImage(UIImage(systemName: "eye.slash"),
                                                  for: .normal)
            }
        }
    }
    
    //MARK: View Lifecycle methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        configureView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unconfigureView()
    }
    
    func reset() {
        showUnpaintedWalls = true
    }
}

//MARK: - Configure UI
extension FloorplanViewController {
    private func configureView() {
        createARView()
        updateARLabelStatus()
        configureBindings()
        arController?.startScene(reset: true)
    }
    
    private func unconfigureView() {
        texturePickerCollectionView.arController = nil
        colorPickerCollectionView.arController = nil
        arController = nil
        arscnView?.removeFromSuperview()
        arscnView = nil
    }
}

//MARK: - Create and configure ARView
extension FloorplanViewController {
    private func createARView() {
        addAndConfigureARViews()
        addGestureOnARView()
        
        arController?.setColor(paint: ColorPicker.colors[0].color)
        
        colorPickerCollectionView.colorPicker = ColorPicker.colors
        colorPickerCollectionView.arController = arController
        
        texturePickerCollectionView.texturePicker = TexturePicker.textures
        texturePickerCollectionView.arController = arController
    }
    
    private func addAndConfigureARViews() {
        arscnView = ARSCNView()
        guard let arscnView = arscnView
        else { return }
        
        view.addSubview(arscnView)
        view.sendSubviewToBack(arscnView)
        arscnView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            arscnView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                               constant: 0),
            arscnView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                           constant: 0),
            arscnView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                constant: 0),
            arscnView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                              constant: 0)
        ])
        
        arController = RemodelARLib.makeFloorplanARController(with: arscnView)
    }
    
    private func configureBindings() {
        arController?.cameraAimInfoUpdated = { cameraAimInfo in
            guard let cameraAimInfo = cameraAimInfo
            else { return }
            
            print("cameraAim: \(cameraAimInfo.angle), \(cameraAimInfo.surfaceType)")
        }
        arController?.wallPainted = {
            print("a wall was painted!")
        }
        arController?.trackingReady = { isReady in
            print("Tracking Ready: \(isReady ? "true" : "false")")
        }
    }
    
    private func addGestureOnARView() {
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(onDraggingARView(_:)))
        arscnView?.isUserInteractionEnabled = true
        arscnView?.addGestureRecognizer(dragGesture)
    }
    
    @objc private func onDraggingARView(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
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
        arController?.trackingReady = { [weak self] isReadyForTracking in
            DispatchQueue.main.async {
                self?.trackingLabel.text = "Tracking Ready: \(isReadyForTracking ? "On" : "Off")"
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
extension FloorplanViewController {
    @IBAction func onThresholdSliderChanged(_ sender: UISlider) {
        arController?.setColorThreshold(threshold: sender.value)
    }
    
    @IBAction func showUITapped(_ sender: PaintyButton) {
        showUI = true
    }
    
    @IBAction func onFinishCornersTapped(_ sender: PaintyButton) {
        arController?.finishCorners(closeShape: false)
    }
    
    @IBAction func onFinishHeightTapped(_ sender: PaintyButton) {
        arController?.finishHeight()
    }
    
    @IBAction func onCancelWallTapped(_ sender: PaintyButton) {
        arController?.endAddWall()
    }
    
    @IBAction func onToggleUnpaintedWallsTapped(_ sender: PaintyButton) {
        print("before: \(showUnpaintedWalls ? "true" : "false")")
        showUnpaintedWalls.toggle()
        arController?.showUnpaintedWalls(visible: showUnpaintedWalls)
        print("after: \(showUnpaintedWalls ? "true" : "false")")
    }
    
    @IBAction func onSavePhotoTapped(_ sender: PaintyButton) {
        guard let photo = arController?.savePhoto()
        else { return }
        
        let activityViewController = UIActivityViewController(activityItems: [photo],
                                                              applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func onSaveMeshTapped(_ sender: PaintyButton) {
        arController?.save3DModel()
    }
    
    @IBAction func onResetTapped(_ sender: PaintyButton) {
        reset()
        arController?.resetScene()
    }
    
    @IBAction func onGetPaintedWallsInfoTapped(_ sender: PaintyButton) {
        guard let paintInfo = arController?.retrievePaintInfo()
        else { return }
        
        print("Paint Info:")
        for wall in paintInfo.paintedWalls {
            print("\(wall.id): \(wall.area.width)x\(wall.area.height), \(wall.paint.color.printUInt)")
        }
    }
    
    @IBAction func onToggleUITapped(_ sender: PaintyButton) {
        showUI.toggle()
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
}

//MARK: - Touches

extension FloorplanViewController {
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first
        else { return }
        
        let point = touch.location(in: arscnView)
        arController?.handleTouch(point: point)
    }
}

extension UITabBarController {
    /// Extends the size of the `UITabBarController` view frame, pushing the tab bar controller off screen.
    /// - Parameters:
    ///   - hidden: Hide or Show the `UITabBar`
    ///   - animated: Animate the change
    func setTabBarHidden(_ hidden: Bool, animated: Bool) {
        guard let vc = selectedViewController else { return }
        guard tabBarHidden != hidden else { return }
        
        let frame = self.tabBar.frame
        let height = frame.size.height
        let offsetY = hidden ? height : -height

        UIViewPropertyAnimator(duration: animated ? 0.3 : 0, curve: .easeOut) {
            self.tabBar.frame = self.tabBar.frame.offsetBy(dx: 0, dy: offsetY)
            self.selectedViewController?.view.frame = CGRect(
                x: 0,
                y: 0,
                width: vc.view.frame.width,
                height: vc.view.frame.height + offsetY
            )
            
            self.view.setNeedsDisplay()
            self.view.layoutIfNeeded()
        }
        .startAnimation()
    }
    
    /// Is the tab bar currently off the screen.
    private var tabBarHidden: Bool {
        tabBar.frame.origin.y >= UIScreen.main.bounds.height
    }
}
