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
    @IBOutlet weak var scanButton: PaintyButton!
    @IBOutlet weak var finishCornersButton: PaintyButton!
    @IBOutlet weak var finishHeightButton: PaintyButton!
    @IBOutlet weak var undoButton: PaintyButton!
    @IBOutlet weak var userMessage: UILabel!
    
    //MARK: Properties
    private var arscnView: ARSCNView?
    private var arController: ARController?
    private var state: FloorplanState = .noFloor {
        didSet {
            updateView()
        }
    }
    
    private var activeColor: WallPaint = ColorPicker.colors[0].color {
        didSet {
            arController?.setColor(paint: activeColor, texture: activeTexture)
        }
    }
    
    private var activeTexture: UIImage? {
        didSet {
            arController?.setColor(paint: activeColor, texture: activeTexture)
        }
    }
    
    private var numCornersPlaced: Int = 0 {
        didSet {
            print("numCornersPlaced: \(numCornersPlaced)")
            updateView()
        }
    }
    
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureView()
        state = .noFloor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unconfigureView()
    }
    
    func reset() {
        showUnpaintedWalls = true
        state = .noFloor
        numCornersPlaced = 0
    }
    
    func updateView() {
        switch state {
        case .noFloor:
            userMessage.isHidden = true
            scanButton.isHidden = false
            finishCornersButton.isHidden = true
            finishHeightButton.isHidden = true
            undoButton.isHidden = true
            colorPickerCollectionView.isHidden = true
            texturePickerCollectionView.isHidden = true
            buttonsTopStackView.isHidden = true
            
        case .scanningFloor:
            userMessage.isHidden = false
            userMessage.text = "Scanning floor..."
            scanButton.isHidden = true
            finishCornersButton.isHidden = true
            finishHeightButton.isHidden = true
            undoButton.isHidden = true
            colorPickerCollectionView.isHidden = true
            texturePickerCollectionView.isHidden = true
            buttonsTopStackView.isHidden = true
            
        case .settingCorners:
            userMessage.isHidden = false
            if numCornersPlaced == 0 {
                userMessage.text = "Tap to place a corner"
            } else if numCornersPlaced < 3 {
                userMessage.text = "Continue tapping to place corners"
            } else if numCornersPlaced >= 3 {
                userMessage.text = "Continue placing corners, then finish by placing a point on the starting point or tapping 'Finish Corners'"
            }
            scanButton.isHidden = true
            finishCornersButton.isHidden = numCornersPlaced < 3
            finishHeightButton.isHidden = true
            undoButton.isHidden = numCornersPlaced < 1
            colorPickerCollectionView.isHidden = true
            texturePickerCollectionView.isHidden = true
            buttonsTopStackView.isHidden = true
            
        case .settingHeight:
            userMessage.isHidden = false
            userMessage.text = "Drag with your finger to set the wall height"
            scanButton.isHidden = true
            finishCornersButton.isHidden = true
            finishHeightButton.isHidden = false
            undoButton.isHidden = true
            colorPickerCollectionView.isHidden = true
            texturePickerCollectionView.isHidden = true
            buttonsTopStackView.isHidden = true
            
        case .painting:
            userMessage.isHidden = true
            scanButton.isHidden = true
            finishCornersButton.isHidden = true
            finishHeightButton.isHidden = true
            undoButton.isHidden = true
            colorPickerCollectionView.isHidden = false
            texturePickerCollectionView.isHidden = false
            buttonsTopStackView.isHidden = false
        }
    }
}

//MARK: - Configure UI
extension FloorplanViewController {
    private func configureView() {
        createARView()
        configureBindings()
        arController?.startScene(reset: true)
    }
    
    private func unconfigureView() {
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
        colorPickerCollectionView.didSelectColor = { [weak self] color in
            self?.activeColor = color
        }
        
        texturePickerCollectionView.texturePicker = TexturePicker.textures
        texturePickerCollectionView.didSelectTexture = { [weak self] texture in
            self?.activeTexture = texture
        }
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
        
        arController = RemodelARLib.makeFloorplanARController(with: arscnView)
    }
    
    private func configureBindings() {
        arController?.cameraAimInfoUpdated = { cameraAimInfo in
            guard let cameraAimInfo = cameraAimInfo
            else { return }
            
//            print("cameraAim: \(cameraAimInfo.angle), \(cameraAimInfo.surfaceType)")
        }
        arController?.wallPainted = {
            print("a wall was painted!")
        }
        arController?.trackingReady = { [weak self] isReady in
            self?.trackingLabel.text = "Tracking Ready: \(isReady ? "yes" : "no")"
            if isReady {
                self?.state = .settingCorners
            }
        }
        arController?.retrievedPaintInfo = { paintInfo in
            print("Paint Info:")
            for wall in paintInfo.paintedWalls {
                print("\(wall.id): \(wall.area.width)x\(wall.area.height), \(wall.paint.color.printUInt)")
            }
        }
        arController?.floorplanCornerCountUpdated = { [weak self] numCorners in
            self?.numCornersPlaced = numCorners
        }
        arController?.floorplanShapeClosed = { [weak self] in
            self?.state = .settingHeight
        }
        arController?.floorplanFinishedSettingWallHeight = { [weak self] in
            self?.state = .painting
        }
    }
    
    private func addGestureOnARView() {
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(onDraggingARView(_:)))
        arscnView?.isUserInteractionEnabled = true
        arscnView?.addGestureRecognizer(dragGesture)
    }
    
    @objc private func onDraggingARView(_ sender: UIPanGestureRecognizer) {
        let point = sender.location(in: arscnView)
        
        switch sender.state {
        case .changed:
            arController?.dragStart(point: point)
            arController?.dragMove(point: point)
            
        case .ended:
            arController?.dragEnd(point: point)
            
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

//MARK: - IBActions
extension FloorplanViewController {
    @IBAction func onThresholdSliderChanged(_ sender: UISlider) {
        arController?.setColorThreshold(threshold: sender.value)
    }
    
    @IBAction func showUITapped(_ sender: PaintyButton) {
        showUI = true
    }
    
    @IBAction func onScanTapped(_ sender: PaintyButton) {
        arController?.startFloorScan(timeout: 5)
        state = .scanningFloor
    }
    
    @IBAction func onFinishCornersTapped(_ sender: PaintyButton) {
        arController?.finishCorners(closeShape: false)
        state = .settingHeight
    }
    
    @IBAction func onFinishHeightTapped(_ sender: PaintyButton) {
        arController?.finishHeight()
        state = .painting
    }
    
    @IBAction func undoCornerTapped(_ sender: PaintyButton) {
        arController?.removeLastCorner()
    }
    
    @IBAction func onToggleUnpaintedWallsTapped(_ sender: PaintyButton) {
        print("before: \(showUnpaintedWalls ? "true" : "false")")
        showUnpaintedWalls.toggle()
        arController?.showUnpaintedWalls(visible: showUnpaintedWalls)
        print("after: \(showUnpaintedWalls ? "true" : "false")")
    }
    
    @IBAction func onSavePhotoTapped(_ sender: PaintyButton) {
        arController?.hideOutlineState()
        
        guard let photo = arController?.savePhoto()
        else { return }
        
        arController?.restoreOutlineState()
        
        let activityViewController = UIActivityViewController(activityItems: [photo],
                                                              applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func onSaveMeshTapped(_ sender: PaintyButton) {
        arController?.save3DModel(callback: { [weak self] fileUrl in
            guard let self = self
            else { return }
            
            let filename = FileManager.documentsFolder.appendingPathComponent("Mesh.usdz")
            if FileManager.default.fileExists(atPath: filename.path) {
                let activityViewController = UIActivityViewController(
                    activityItems: [filename],
                    applicationActivities: nil
                )
                present(activityViewController, animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func onResetTapped(_ sender: PaintyButton) {
        reset()
        arController?.resetScene()
    }
    
    @IBAction func onGetPaintedWallsInfoTapped(_ sender: PaintyButton) {
        arController?.retrievePaintInfo()
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

private enum FloorplanState {
    case noFloor
    case scanningFloor
    case settingCorners
    case settingHeight
    case painting
}
