//
//  RoomPlanView.swift
//  Painty
//
//  Created by Davido Hyer on 4/23/24.
//

import ARKit
import Combine
import SwiftUI
import RemodelAR

struct RoomPlanView: View {
    @EnvironmentObject var settings: SettingsData
    
    var body: some View {
        ZStack {
            arView
                .edgesIgnoringSafeArea(.all)
            if settings.uiVisible {
                if settings.roomPlanViewMode == .painting {
                    VStack {
                        Spacer(minLength: 40)
                        VStack {
                            HStack {
                                Spacer(minLength: 15)
                                savePhotoButton
                                save3DModelButton
                                resetSceneButton
                                getPaintInfoButton
                                Spacer(minLength: 80)
                            }
                            HStack {
                                Text("Coaching: \(settings.coachingVisible ? "on" : "off")")
                                Text("Tracking Ready: \(settings.trackingReady ? "yes" : "no")")
                            }
//                            occlusionColorPicker
//                            thresholdSlider
//                            occlusionSlider
                        }
                        VStack {
                            if !settings.roomPlanInstruction.isEmpty {
                                instructionText
                            }
                        }.offset(y: 40)
                        VStack {
                            Spacer()
                            HStack {
                                lidarOcclusionButton
                                if settings.currentSelectedWallId != nil {
                                    deleteWallButton
                                }
                                toggleEditModeButton
                            }
                            texturePicker
                            colorPicker
                        }
                    }.padding([.bottom], 80)
                } else if settings.roomPlanViewMode == .scanning {
                    VStack {
                        Spacer()
                        HStack {
//                            startScanningButton
                            doneScanningButton
                        }.padding([.bottom], 240)
                    }.padding([.top], 40)
                } else if settings.roomPlanViewMode == .reviewing {
                    VStack {
                        Spacer()
                        HStack {
                            finishScanReviewButton
                        }.padding([.bottom], 100)
                    }.padding([.top], 40)
                } else if settings.roomPlanViewMode == .editingPatches {
                    VStack {
                        Spacer()
                        VStack {
                            HStack {
                                addPatchButton
                                removePatchButton
                                resetPatchesButton
                            }
                            HStack {
                                if settings.isEditPatchSelected {
                                    togglePatchTypeButton
                                    deletePatchButton
                                }
                                toggleEditModeButton
                            }
                        }
                    }.padding([.bottom], 120)
                } else if settings.roomPlanViewMode == .creatingPatch {
                    VStack {
                        Spacer()
                        VStack {
                            HStack {
                                cancelPatchButton
                            }
                        }.offset(y: -40)
                    }.padding([.bottom], 80)
                } else if settings.roomPlanViewMode == .initializing {
                    VStack {
                        Spacer()
                        VStack {
                            HStack {
                                startScanningButton
                            }
                        }.offset(y: -40)
                    }.padding([.bottom], 110)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + settings.contextSwitchDelay) {
                settings.model.setColor(
                    paint: activeColor,
                    texture: activeTexture
                )
                // Uncomment to customize the UI colors
                //            customizeColorTheme()
                setupBindings()
                settings.roomPlanViewMode = .initializing
                //            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                //            }
                settings.model.setRoomPlanOcclusionVisibility(enableAll2D: true,
                                                              enableAll3D: false)
//                self.settings.model.startScene(reset: true)
            }
        }
    }
    
    func customizeColorTheme() {
        settings.model.setDeselectedColor(color: .blue)
        settings.model.setSelectedColor(color: .purple)
    }
    
    func setupBindings() {
        settings.modeSwitched()
        settings.model.paintInfo.sink { [self] paintInfo in
            guard let paintInfo = paintInfo else { return }
            var output = [String]()
            if paintInfo.ceilingArea > 0 {
                output.append("Ceiling: \(paintInfo.ceilingArea.truncated()) m²")
            }
            if paintInfo.totalWallArea > 0 {
                output.append("Total Wall Area: \(paintInfo.totalWallArea.truncated()) m²")
            }
            if paintInfo.totalPaintableArea > 0 {
                output.append("Total Paint Area: \(paintInfo.totalPaintableArea.truncated()) m²")
            }
            if paintInfo.occlusionInfo.totalUserOcclusionAddArea > 0 {
                output.append("User Add Area: \(paintInfo.occlusionInfo.totalUserOcclusionAddArea.truncated()) m²")
            }
            if paintInfo.occlusionInfo.totalUserOcclusionRemoveArea > 0 {
                output.append("User Remove Area: \(paintInfo.occlusionInfo.totalUserOcclusionRemoveArea.truncated()) m²")
            }
            showDebugMessage(message: output.joined(separator: "\n"))
        }.store(in: &settings.model.cancellables)
        
        settings.model.coachingVisible.sink { [self] coachingVisible in
            settings.coachingVisible = coachingVisible
        }.store(in: &settings.model.cancellables)
        
        settings.model.trackingReady.sink { [self] trackingReady in
            settings.trackingReady = trackingReady
        }.store(in: &settings.model.cancellables)
        
        settings.model.arTrackingState.sink { state in
            // Do something with state
        }.store(in: &settings.model.cancellables)
        
        settings.model.roomPlanOcclusionTypes.sink { types in
            var surf = [String: Bool]()
            for type in types.surfaces {
                surf[type] = false
            }
            
            var obj = [String: Bool]()
            for type in types.objects {
                obj[type] = false
            }
            settings.model.setRoomPlanOcclusionVisibility(surfaces: surf, objects: obj)
        }.store(in: &settings.model.cancellables)
        
        settings.model.roomPlanInstructionUpdated
            .receive(on: RunLoop.main)
            .sink { instruction in
                settings.roomPlanInstruction = instruction.description
            }
            .store(in: &settings.model.cancellables)
        
        settings.model.planarMeshCount
            .receive(on: RunLoop.main)
            .sink { count in
                if settings.roomPlanViewMode == .initializing {
                    if count >= 1 {
                        settings.roomPlanViewMode = .scanning
                    }
                }
            }
            .store(in: &settings.model.cancellables)
        
        settings.model.roomPlanFailed
            .receive(on: RunLoop.main)
            .sink { error in
                if error == .worldTrackingFailure {
                    settings.reset()
                }
            }
            .store(in: &settings.model.cancellables)
        
        settings.model.currentSelectedWallId.sink { id in
            settings.currentSelectedWallId = id
        }.store(in: &settings.model.cancellables)
        
        settings.model.isEditPatchSelected.sink { isSelected in
            settings.isEditPatchSelected = isSelected
        }.store(in: &settings.model.cancellables)
        
        settings.model.patchStateChanged.sink { state in
            switch state {
            case .adding:
                settings.roomPlanViewMode = .creatingPatch
                
            case .editing:
                settings.roomPlanViewMode = .editingPatches
            }
        }.store(in: &settings.model.cancellables)
    }
}
 
private extension RoomPlanView {
    var arView: some View {
        RemodelARLib.makeARView(model: settings.model, arMethod: .RoomPlan)
            .modifier(DragActions(
                onDragStart: { point in
                    settings.model.dragStart(point: point)
                }, onDragMove: { point in
                    settings.model.dragMove(point: point)
                }, onDragEnd: { point in
                    settings.model.dragEnd(point: point)
                })
            )
    }
    
    var activeColor: WallPaint {
        colorItems[settings.colorIndex]
    }
    
    var activeTexture: UIImage? {
        guard settings.textureIndex >= 0
        else { return nil }
        
        return textureImages[settings.textureIndex]
    }
    
    func showDebugMessage(message: String) {
        settings.debugString = message
        settings.debugTimer?.invalidate()
        settings.debugTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { _ in
            settings.debugString = ""
        })
    }
}

private typealias UIControls = RoomPlanView
private extension UIControls {
    var deleteWallButton: some View {
        Button(action: {
            settings.model.deleteWall(id: settings.currentSelectedWallId)
        }, label: {
            Image(systemName: "trash.fill")
                .foregroundColor(.white)
        })
            .padding()
            .background(Color(.sRGB, white: 0, opacity: 0.15))
            .cornerRadius(10)
    }
    
    var occlusionSlider: some View {
        Slider(value: $settings.depthThreshold, in: -0.5...0.5)
            .padding()
            .valueChanged(value: settings.depthThreshold) { threshold in
                settings.model.setOcclusionDepthThreshold(threshold: Float(threshold))
            }.offset(y: 40)
    }
    
    var lidarOcclusionButton: some View {
        Button(action: {
            settings.lidarOcclusionScanActive.toggle()
            if settings.lidarOcclusionScanActive {
                settings.model.startLidarOcclusionScan()
            } else {
                settings.model.stopLidarOcclusionScan()
            }
        }, label: {
            if settings.lidarOcclusionScanActive {
                Text("Stop Lidar")
                    .bold()
                    .foregroundColor(.white)
            } else {
                Text("Start Lidar")
                    .bold()
                    .foregroundColor(.white)
            }
        })
            .padding()
            .background(Color(.sRGB, white: 0, opacity: 0.15))
            .cornerRadius(10)
    }
    
    var unpaintedVisibleButton: some View {
        Button(action: {
            settings.unpaintedVisible.toggle()
            settings.model.showUnpaintedWalls(visible: settings.unpaintedVisible)
        }, label: {
            Image(systemName: settings.unpaintedVisible ? "eye.fill" : "eye.slash.fill")
                .foregroundColor(.white)
        })
            .padding()
            .background(Color(.sRGB, white: 0, opacity: 0.15))
            .cornerRadius(10)
    }
    
    var startScanningButton: some View {
        Button(action: {
            settings.model.startScene(reset: true)
            settings.roomPlanViewMode = .scanning
        }, label: {
            Text("Start")
                .bold()
                .foregroundColor(.white)
        })
            .padding()
            .background(Color(.sRGB, white: 0, opacity: 0.15))
            .cornerRadius(10)
    }
    
    var doneScanningButton: some View {
        Button(action: {
            settings.model.finishRoomPlanScan()
            settings.roomPlanViewMode = .reviewing
        }, label: {
            Text("Done")
                .bold()
                .foregroundColor(.white)
        })
            .padding()
            .background(Color(.sRGB, white: 0, opacity: 0.15))
            .cornerRadius(10)
    }
    
    var finishScanReviewButton: some View {
        Button(action: {
            settings.model.finishRoomPlanReview()
            settings.roomPlanViewMode = .painting
        }, label: {
            Text("Start Painting")
                .bold()
                .foregroundColor(.white)
        })
        .padding()
        .background(Color(.sRGB, white: 0, opacity: 0.15))
        .cornerRadius(10)
    }
     
    var savePhotoButton: some View {
        Button(action: {
            settings.model.sharePhoto(hideOutline: true)
        }, label: {
            Image(systemName: "camera.fill")
                .foregroundColor(.white)
        })
            .padding()
            .background(Color(.sRGB, white: 0, opacity: 0.15))
            .cornerRadius(10)
    }
    
    var save3DModelButton: some View {
        Button(action: {
            settings.model.save3DModel()
        }, label: {
            Image("saveMesh")
                .foregroundColor(.white)
        })
            .padding()
            .background(Color(.sRGB, white: 0, opacity: 0.15))
            .cornerRadius(10)
    }
    
    var resetSceneButton: some View {
        Button(action: {
            settings.reset()
            settings.model.setColor(
                paint: activeColor,
                texture: activeTexture
            )
        },
               label: {
            Image("reset")
                .foregroundColor(.white)
        })
            .padding()
            .background(Color(.sRGB, white: 0, opacity: 0.15))
            .cornerRadius(10)
    }
    
    var thresholdSlider: some View {
        Slider(value: $settings.occlusionThreshold, in: 4...30)
            .padding()
            .valueChanged(value: settings.occlusionThreshold) { threshold in
                settings.model.setColorThreshold(threshold: Float(threshold))
            }.offset(y: 40)
    }
    var occlusionColorPicker: some View {
        let modes = ["C1", "C2", "C3", "AR Picker"]
        return VStack {
            HStack(spacing: 5) {
                ForEach(0..<modes.count, id: \.self) {
                    let index = $0
                    let mode = modes[index]
                    Button(action: {
                        if let touchMode = TouchMode(rawValue: index) {
                            settings.model.setTouchMode(mode: touchMode)
                            settings.touchModeIndex = index
                        }
                    },
                           label: {
                        Text("\(mode)")
                            .bold()
                            .foregroundColor(.white)
                    })
                        .padding(EdgeInsets(top: 17, leading: 12, bottom: 17, trailing: 12))
                        .background(
                            Color(
                                .sRGB,
                                white: 0,
                                opacity: settings.touchModeIndex == index ? 0.75 : 0.15
                            )
                        )
                        .cornerRadius(10)
                }
                unpaintedVisibleButton
            }
            if settings.touchModeIndex < 3 {
                Text("Setting occlusion color \(settings.touchModeIndex + 1),\n*AR touch won't work until AR Picker is selected")
                    .font(.system(size: 14))
            }
        }.offset(y: 40)
    }
    
    var getPaintInfoButton: some View {
        Button(action: {
            settings.model.retrievePaintInfo()
        },
               label: {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.white)
        })
            .padding()
            .background(Color(.sRGB, white: 0, opacity: 0.15))
            .cornerRadius(10)
    }
    
    var debugText: some View {
        Text(settings.debugString)
            .bold()
            .padding(.all)
            .foregroundColor(.white)
            .background(Color(.sRGB, white: 0, opacity: 0.25))
            .cornerRadius(10)
            .lineLimit(8)
    }
    
    var instructionText: some View {
        Text(settings.roomPlanInstruction)
            .bold()
            .padding(.all)
            .foregroundColor(.white)
            .background(Color(.sRGB, white: 0, opacity: 0.25))
            .cornerRadius(10)
            .lineLimit(8)
    }
}

private typealias ColorPicker = RoomPlanView
private extension ColorPicker {
    var colorItems: [WallPaint] {
        ColorRepo.colors().map({ WallPaint(id: "", name: "", color: $0) })
    }
    
    var colorPicker: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(0..<colorItems.count, id: \.self) { i in
                    Button {
                        settings.showStroke = true
                        settings.colorIndex = i
                        settings.model.setColor(
                            paint: activeColor,
                            texture: activeTexture
                        )
                    } label: {
                        RoundedRectangle(cornerRadius: 17)
                            .strokeBorder(
                                lineWidth: (settings.showStroke && i == settings.colorIndex) ? 5 : 0
                            )
                            .foregroundColor(.white)
                            .background(Color(colorItems[i].color))
                            .clipShape(RoundedRectangle(cornerRadius: 17))
                            .frame(width: 74, height: 74)
                            .animation(.interpolatingSpring(stiffness: 60,
                                                            damping: 15),
                                       value: settings.showStroke && i == settings.colorIndex)

                    }
                    .onTapGesture {
                        settings.showStroke = true
                    }
                }
            }
            .padding()
        }
    }
}

private typealias TexturePicker = RoomPlanView
private extension TexturePicker {
    var textureNames: [String] {
        [
            "venetianWall",
            "plasterWall",
            "renaissanceWall",
            "brickWall",
            "cinderWall",
            "pebbleWall",
            "stoneWall"
        ]
    }
    
    var textureImages: [UIImage] {
        textureNames.compactMap({ UIImage(named: $0) })
    }
    
    var texturePicker: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(0..<textureImages.count, id: \.self) { i in
                    Button {
                        if i == settings.textureIndex {
                            settings.showTextureStroke = false
                            settings.textureIndex = -1
                        } else {
                            settings.showTextureStroke = true
                            settings.textureIndex = i
                        }
                        settings.model.setColor(
                            paint: activeColor,
                            texture: activeTexture
                        )
                    } label: {
                        RoundedRectangle(cornerRadius: 17)
                            .strokeBorder(
                                lineWidth: (settings.showTextureStroke && i == settings.textureIndex) ? 5 : 0
                            )
                            .foregroundColor(.white)
                            .background(
                                Image(uiImage: textureImages[i])
                                    .resizable()
                                    .frame(width: 200, height: 200)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 17))
                            .frame(width: 74, height: 74)
                            .animation(.interpolatingSpring(stiffness: 60,
                                                            damping: 15),
                                       value: settings.showTextureStroke && i == settings.textureIndex)
                    }
                    .onTapGesture {
                        settings.showTextureStroke.toggle()
                    }
                }
            }
            .padding()
        }.offset(y: 30)
    }
}

private typealias Occlusions = RoomPlanView
private extension Occlusions {
    var addPatchButton: some View {
        Button(action: {
            settings.model.addEditPatch(type: .add)
            settings.swatchViewMode = .creatingPatch
        }, label: {
            Text("+ Patch")
                .bold()
                .foregroundColor(.white)
        })
        .padding()
        .background(Color(.sRGB, white: 0, opacity: 0.15))
        .cornerRadius(10)
    }
    
    var removePatchButton: some View {
        Button(action: {
            settings.model.addEditPatch(type: .remove)
            settings.swatchViewMode = .creatingPatch
        }, label: {
            Text("- Patch")
                .bold()
                .foregroundColor(.white)
        })
        .padding()
        .background(Color(.sRGB, white: 0, opacity: 0.15))
        .cornerRadius(10)
    }
    
    var togglePatchTypeButton: some View {
        Button(action: {
            settings.model.toggleSelectedPatchType()
        }, label: {
            Text("Switch Patch")
                .bold()
                .foregroundColor(.white)
        })
        .padding()
        .background(Color(.sRGB, white: 0, opacity: 0.15))
        .cornerRadius(10)
    }
    
    var toggleEditModeButton: some View {
        Button(action: {
            let isActive = !settings.isEditModeActive
            settings.isEditModeActive = isActive
            if isActive {
                settings.roomPlanViewMode = .editingPatches
            } else {
                settings.roomPlanViewMode = .painting
            }
            settings.model.setPatchEditing(enabled: isActive)
        },
               label: {
            Text(settings.isEditModeActive ? "Done" : "Edit")
                .bold()
                .foregroundColor(.white)
        })
        .padding()
        .background(Color(.sRGB, white: 0, opacity: 0.15))
        .cornerRadius(10)
    }
    
    var deletePatchButton: some View {
        Button(action: {
            settings.model.deleteSelectedPatch()
        },
               label: {
            Image(systemName: "trash.fill")
                .foregroundColor(.white)
        })
        .padding()
        .background(Color(.sRGB, white: 0, opacity: 0.15))
        .cornerRadius(10)
    }
    
    var resetPatchesButton: some View {
        Button(action: {
            settings.model.resetEditPatches()
        },
               label: {
            Image("reset")
                .foregroundColor(.white)
        })
        .padding()
        .background(Color(.sRGB, white: 0, opacity: 0.15))
        .cornerRadius(10)
    }
    
    var cancelPatchButton: some View {
        Button(action: {
            settings.model.cancelEditPatch()
        },
               label: {
            Image(systemName: "circle.slash")
                .foregroundColor(.white)
        })
        .padding()
        .background(Color(.sRGB, white: 0, opacity: 0.15))
        .cornerRadius(10)
    }
}

struct RoomPlanView_Previews: PreviewProvider {
    static var previews: some View {
        RoomPlanView()
            .environmentObject(SettingsData())
    }
}
