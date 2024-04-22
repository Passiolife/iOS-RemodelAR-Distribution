//
//  FloorplanView.swift
//  Painty
//
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import ARKit
import Combine
import SwiftUI
import RemodelAR

struct FloorplanView: View {
    @EnvironmentObject var settings: SettingsData
    
    var body: some View {
        ZStack {
            arView
                .edgesIgnoringSafeArea(.all)
            if settings.uiVisible {
                if settings.floorplanState == .painting {
                    VStack {
                        VStack {
                            HStack {
                                savePhotoButton
                                save3DModelButton
                                resetSceneButton
                                getPaintInfoButton
                            }
                            HStack {
                                Text("Coaching: \(settings.coachingVisible ? "on" : "off")")
                                Text("Tracking Ready: \(settings.trackingReady ? "yes" : "no")")
                            }
                            if !settings.debugString.isEmpty {
                                debugText
                            }
                            occlusionColorPicker
                            thresholdSlider
                        }
                        Spacer()
                    }.padding([.top], 40)
                }
                VStack {
                    Spacer()
                    VStack {
                        VStack {
                            switch settings.floorplanState {
                            case .noFloor:
                                scanButton
                            case .scanningFloor:
                                Text("Scanning floor...")
                                    .bold()
                                    .foregroundColor(.white)
                            case .settingCorners:
                                placeCornersMessage
                                if settings.numberOfFloorCorners > 2 {
                                    finishCornersButton
                                }
                            case .settingHeight:
                                Text("Drag with your finger to set the wall height")
                                    .bold()
                                    .foregroundColor(.white)
                                finishHeightButton
                            case .painting:
                                EmptyView()
                            }
                        }
                    }.offset(y: -60)
                    if settings.floorplanState == .painting {
                        VStack {
                            texturePicker
                            colorPicker
                        }
                    }
                }.padding([.bottom], 80)
            }
        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                settings.reset()
                settings.model.setColor(paint: activeColor, texture: activeTexture)
                setupBindings()
            }
        }
    }
    
    func setupBindings() {
        settings.model.paintInfo.sink { [self] paintInfo in
            guard let paintInfo = paintInfo else { return }
            var output = [String]()
            for wall in paintInfo.paintedWalls {
                output.append("\(wall.area.width.formatted())x\(wall.area.height.formatted()) (\(wall.area.area.formatted()) m²)")
            }
            showDebugMessage(message: output.joined(separator: "\n"))
        }.store(in: &settings.model.cancellables)
        
        settings.model.coachingVisible.sink { [self] coachingVisible in
            settings.coachingVisible = coachingVisible
        }.store(in: &settings.model.cancellables)
        
        settings.model.trackingReady.sink { [self] trackingReady in
            settings.trackingReady = trackingReady
            if trackingReady {
                settings.floorplanState = .settingCorners
            }
        }.store(in: &settings.model.cancellables)
        
        settings.model.floorplanCornerCount.sink { [self] cornerCount in
            settings.numberOfFloorCorners = cornerCount
        }.store(in: &settings.model.cancellables)
        
        settings.model.floorplanShapeClosed.sink { [self] in
            settings.floorplanState = .settingHeight
        }.store(in: &settings.model.cancellables)
        
        settings.model.floorplanFinishedSettingWallHeight.sink { [self] in
            settings.floorplanState = .painting
        }.store(in: &settings.model.cancellables)
    }
    
    var arView: some View {
        RemodelARLib.makeARView(model: settings.model, arMethod: .Floorplan)
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
    
    var scanButton: some View {
        Button(action: {
            settings.model.startFloorScan()
            settings.floorplanState = .scanningFloor
        }, label: {
            Text(settings.floorplanState == .scanningFloor ? "Stop Scan" : "Start Floor Scan")
                .bold()
                .foregroundColor(.white)
        })
            .padding()
            .background(Color(.sRGB, white: 0, opacity: 0.15))
            .cornerRadius(10)
    }
    
    var placeCornersMessage: some View {
        var message = ""
        if settings.numberOfFloorCorners == 0 {
            message = "Tap to place a corner"
        } else if settings.numberOfFloorCorners < 3 {
            message = "Continue tapping to place corners"
        } else if settings.numberOfFloorCorners >= 3 {
            message = "Continue placing corners, then finish by placing a point on the starting point or tapping 'Finish Corners'"
        }
        return Text(message)
            .bold()
            .foregroundColor(.white)
    }
    
    var finishCornersButton: some View {
        Button(action: {
            settings.model.finishCorners(closeShape: false)
            settings.floorplanState = .settingHeight
        }, label: {
            Text("Finish Corners")
                .bold()
                .foregroundColor(.white)
        })
            .padding()
            .background(Color(.sRGB, white: 0, opacity: 0.15))
            .cornerRadius(10)
    }
    
    var finishHeightButton: some View {
        Button(action: {
            settings.model.finishHeight()
            settings.floorplanState = .painting
        }, label: {
            Text("Finish Height")
                .bold()
                .foregroundColor(.white)
        })
            .padding()
            .background(Color(.sRGB, white: 0, opacity: 0.15))
            .cornerRadius(10)
    }
    
    var cancelAddWallButton: some View {
        Button(action: { settings.model.cancelAddWall() },
               label: {
            Text("Cancel Wall")
                .bold()
                .foregroundColor(.white)
        })
            .padding()
            .background(Color(.sRGB, white: 0, opacity: 0.15))
            .cornerRadius(10)
    }
    
    var savePhotoButton: some View {
        Button(action: {
            settings.model.sharePhoto()
        }, label: {
            Image(systemName: "camera.fill")
                .foregroundColor(.white)
        })
            .padding()
            .background(Color(.sRGB, white: 0, opacity: 0.15))
            .cornerRadius(10)
    }
    
    var save3DModelButton: some View {
        Button(action: { settings.model.save3DModel() }, label: {
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
                        .background(Color(.sRGB, white: 0, opacity: settings.touchModeIndex == index ? 0.75 : 0.15))
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
        Button(action: { settings.model.retrievePaintInfo() },
               label: {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.white)
        })
            .padding()
            .background(Color(.sRGB, white: 0, opacity: 0.15))
            .cornerRadius(10)
    }
    
    var debugText: some View {
        VStack(alignment: .center, spacing: nil, content: {
            Text(settings.debugString)
                .bold()
                .padding(.all)
                .foregroundColor(.white)
                .background(Color(.sRGB, white: 0, opacity: 0.25))
                .cornerRadius(10)
            Spacer()
        })
    }
    
    func showDebugMessage(message: String) {
        settings.debugString = message
        settings.debugTimer?.invalidate()
        settings.debugTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { _ in
            settings.debugString = ""
        })
    }
}

private extension FloorplanView {
    var colorItems: [WallPaint] {
        ColorRepo.colors().enumerated().map({ WallPaint(id: "\($0.offset)",
                                                        name: "\($0.offset)",
                                                        color: $0.element) })
    }
    
    var colorPicker: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(0..<colorItems.count, id: \.self) { i in
                    Button {
                        settings.showStroke = true
                        settings.colorIndex = i
                        settings.model.setColor(paint: activeColor, texture: activeTexture)
                    } label: {
                        RoundedRectangle(cornerRadius: 17)
                            .strokeBorder(lineWidth: (settings.showStroke && i == settings.colorIndex) ? 5 : 0)
                            .foregroundColor(.white)
                            .background(Color(colorItems[i].color))
                            .clipShape(RoundedRectangle(cornerRadius: 17))
                            .frame(width: 74, height: 74)
                            .animation(.interpolatingSpring(stiffness: 60, damping: 15), 
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

private extension FloorplanView {
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
//                ForEach(0..<colorItems.count, id: \.self) { i in
                ForEach(0..<textureImages.count, id: \.self) { i in
                    Button {
                        if i == settings.textureIndex {
                            settings.showTextureStroke = false
                            settings.textureIndex = -1
                        } else {
                            settings.showTextureStroke = true
                            settings.textureIndex = i
                        }
                        settings.model.setColor(paint: activeColor, texture: activeTexture)
                    } label: {
                        RoundedRectangle(cornerRadius: 17)
                            .strokeBorder(lineWidth: (settings.showTextureStroke && i == settings.textureIndex) ? 5 : 0)
                            .foregroundColor(.white)
                            .background(
                                Image(uiImage: textureImages[i])
                                    .resizable()
                                    .frame(width: 200, height: 200)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 17))
                            .frame(width: 74, height: 74)
                            .animation(.interpolatingSpring(stiffness: 60, damping: 15),
                                       value: settings.showStroke && i == settings.colorIndex)
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

struct FloorplanView_Previews: PreviewProvider {
    static var previews: some View {
        FloorplanView()
    }
}

enum FloorplanState {
    case noFloor
    case scanningFloor
    case settingCorners
    case settingHeight
    case painting
}
