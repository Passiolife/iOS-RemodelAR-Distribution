//
//  LidarView.swift
//  Painty
//
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import ARKit
import Combine
import SwiftUI
import RemodelAR

struct LidarView: View {
    @EnvironmentObject var settings: SettingsData

    var body: some View {
        ZStack {
            arView
                .edgesIgnoringSafeArea(.all)
            if settings.uiVisible {
                VStack {
                    HStack {
                        savePhotoButton
                        save3DModelButton
                        resetSceneButton
                        getPaintInfoButton
                    }
                    scanModeButton
                    if !settings.debugString.isEmpty {
                        debugText
                    }
                    Text("Planar Meshes: \(settings.planarMeshCount)")
                    occlusionColorPicker
                    thresholdSlider
                    Spacer()
                }.padding([.top], 40)
                VStack {
                    Spacer()
                    texturePicker
                    colorPicker
                }.padding([.bottom], 110)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + settings.contextSwitchDelay) {
                settings.reset()
                settings.model.setColor(paint: activeColor, texture: activeTexture)
                settings.model.startScene()
                setupBindings()
            }
        }
    }

    var arView: some View {
        RemodelARLib.makeARView(model: settings.model, arMethod: .Lidar)
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

    var thresholdSlider: some View {
        Slider(value: $settings.occlusionThreshold, in: 4...30)
            .padding()
            .valueChanged(value: settings.occlusionThreshold) { threshold in
                settings.model.setColorThreshold(threshold: Float(threshold))
            }.offset(y: 40)
    }

    var occlusionColorPicker: some View {
        let modes = ["C1", "C2", "C3", "Brightness"]
        return HStack(spacing: 5) {
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
        }.offset(y: 40)
    }

    var scanModeButton: some View {
        Button(action: {
            switch settings.scanMode {
            case .scanning:
                settings.model.stopLidarScan()
                settings.scanMode = .paused

            case .paused:
                settings.model.startLidarScan()
                settings.scanMode = .scanning
            }
        },
               label: {
            Text(settings.scanMode == .scanning ? "Pause Lidar" : "Start Lidar")
                .bold()
                .foregroundColor(.white)
        })
            .padding()
            .background(Color(.sRGB, white: 0, opacity: 0.15))
            .cornerRadius(10)
    }

    func setupBindings() {
        settings.model.paintInfo.sink { [self] paintInfo in
            guard let paintInfo = paintInfo else { return }
            var output = [String]()
            for wall in paintInfo.paintedWalls {
                output.append("\(wall.area.width.formatted())x\(wall.area.height.formatted()) (\(wall.area.area.formatted()))")
            }
            showDebugMessage(message: output.joined(separator: "\n"))
        }.store(in: &settings.model.cancellables)
        
        settings.model.planarMeshCount.sink { planarMeshCount in
            settings.planarMeshCount = planarMeshCount
        }.store(in: &settings.model.cancellables)
    }
}

private extension LidarView {
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

private extension LidarView {
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
    
    var savePhotoButton: some View {
        Button(action: {
            settings.model.sharePhoto()
            showDebugMessage(message: "Image Saved!")
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
    
    func showDebugMessage(message: String) {
        settings.debugString = message
        settings.debugTimer?.invalidate()
        settings.debugTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { _ in
            settings.debugString = ""
        })
    }
}

private extension LidarView {
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

struct LidarView_Previews: PreviewProvider {
    static var previews: some View {
        LidarView()
    }
}
