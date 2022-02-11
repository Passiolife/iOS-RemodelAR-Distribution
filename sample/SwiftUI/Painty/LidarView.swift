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
                }.padding([.bottom], 80)
            }
        }
        .onAppear {
            settings.reset()
            settings.model.pickColor(paint: colorItems[0])
            setupBindings()
        }
    }

    var arView: some View {
        RemodelARLib.makeARView(model: settings.model, arMethod: .Lidar)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        settings.model.dragStart(point: gesture.startLocation)
                        settings.model.dragMove(point: gesture.location)
                    }
                    .onEnded { _ in
                        settings.model.dragEnd()
                    }
            )
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
                settings.model.setScanMode(scanMode: .paused)
                settings.scanMode = .paused

            case .paused:
                settings.model.setScanMode(scanMode: .scanning)
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
                output.append("estimated: \(wall.area.estimatedActualArea.formatted()) m²")
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
        let numHues = 20
        var colors = [WallPaint]()
        colors.append(WallPaint(id: "0",
                                color: Color(red: 230.0 / 255.0,
                                             green: 224.0 / 255.0,
                                             blue: 200.0 / 255.0).uiColor()))
        colors.append(WallPaint(id: "0",
                                color: Color(red: 220.0 / 255.0,
                                             green: 195.0 / 255.0,
                                             blue: 235.0 / 255.0).uiColor()))
        colors.append(WallPaint(id: "0",
                                color: Color(red: 252.0 / 255.0,
                                             green: 247.0 / 255.0,
                                             blue: 235.0 / 255.0).uiColor()))
        colors.append(WallPaint(id: "0",
                                color: Color(red: 255.0 / 255.0,
                                             green: 255.0 / 255.0,
                                             blue: 251.0 / 255.0).uiColor()))
        colors.append(WallPaint(id: "0",
                                color: Color(red: 58.0 / 255.0,
                                             green: 59.0 / 255.0,
                                             blue: 61.0 / 255.0).uiColor()))
        colors.append(WallPaint(id: "0",
                                color: Color(red: 101.0 / 255.0,
                                             green: 118.0 / 255.0,
                                             blue: 134.0 / 255.0).uiColor()))
        colors.append(WallPaint(id: "0",
                                color: Color(red: 239.0 / 255.0,
                                             green: 234.0 / 255.0,
                                             blue: 196.0 / 255.0).uiColor()))
        colors.append(WallPaint(id: "0",
                                color: Color(red: 125.0 / 255.0,
                                             green: 83.0 / 255.0,
                                             blue: 68.0 / 255.0).uiColor()))
        for i in 0..<numHues {
            let color_8_8 = Color(hue: Double(i) / Double(numHues),
                                  saturation: 0.8,
                                  brightness: 0.8)
            let color_8_6 = Color(hue: Double(i) / Double(numHues),
                                  saturation: 0.8,
                                  brightness: 0.6)
            let color_8_4 = Color(hue: Double(i) / Double(numHues),
                                  saturation: 0.8,
                                  brightness: 0.4)
            let color_8_2 = Color(hue: Double(i) / Double(numHues),
                                  saturation: 0.8,
                                  brightness: 0.2)
            
            colors.append(WallPaint(id: "\(i * 5 + 1)", color: color_8_8.uiColor()))
            colors.append(WallPaint(id: "\(i * 5 + 2)", color: color_8_6.uiColor()))
            colors.append(WallPaint(id: "\(i * 5 + 3)", color: color_8_4.uiColor()))
            colors.append(WallPaint(id: "\(i * 5 + 4)", color: color_8_2.uiColor()))
        }
        return colors
    }
    
    var colorPicker: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(0..<colorItems.count) { i in
                    Button {
                        settings.showStroke = true
                        settings.colorIndex = i
                        settings.model.pickColor(paint: colorItems[i])
                    } label: {
                        RoundedRectangle(cornerRadius: 17)
                            .strokeBorder(lineWidth: (settings.showStroke && i == settings.colorIndex) ? 5 : 0)
                            .foregroundColor(.white)
                            .background(Color(colorItems[i].color))
                            .clipShape(RoundedRectangle(cornerRadius: 17))
                            .frame(width: 74, height: 74)
                            .animation(Animation.interpolatingSpring(stiffness: 60, damping: 15))
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
            settings.model.resetScene()
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
        Button(action: { settings.model.getPaintInfo() },
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
            "ChalkPaints",
            "ConcreteEffects1",
            "ConcreteEffects2",
            "Corium",
            "Ebdaa",
            "Elora",
            "Glostex",
            "GraniteArenal",
            "Khayal_Beauty",
            "Linetex",
            "Marmo",
            "Marotex",
            "Mashasco",
            "Newtex",
            "Rawa",
            "RawaKothban",
            "Said",
            "Texture",
            "Tourmaline",
            "Worood"
        ]
    }

    var textureImages: [UIImage] {
        textureNames.compactMap({ UIImage(named: $0) })
    }

    var texturePicker: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(0..<textureImages.count) { i in
                    Button {
                        if i == settings.textureIndex {
                            settings.showTextureStroke = false
                            settings.textureIndex = -1
                            settings.model.pickTexture(texture: nil)
                        } else {
                            settings.showTextureStroke = true
                            settings.textureIndex = i
                            settings.model.pickTexture(texture: textureImages[i])
                        }
                    } label: {
                        RoundedRectangle(cornerRadius: 17)
                            .strokeBorder(lineWidth: (settings.showTextureStroke && i == settings.textureIndex) ? 5 : 0)
                            .foregroundColor(.white)
                            .background(Image(uiImage: textureImages[i]))
                            .clipShape(RoundedRectangle(cornerRadius: 17))
                            .frame(width: 74, height: 74)
                            .animation(Animation.interpolatingSpring(stiffness: 60, damping: 15))
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
