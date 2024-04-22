//
//  LegacyView.swift
//  Painty
//
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import ARKit
import Combine
import SwiftUI
import RemodelAR

struct LegacyView: View {
    @EnvironmentObject var settings: SettingsData

    var body: some View {
        ZStack {
            arView
                .edgesIgnoringSafeArea(.all)
            if settings.uiVisible {
                VStack {
                    VStack {
                        HStack {
                            savePhotoButton
                            resetSceneButton
                        }
                        HStack {
                            Text("Coaching: \(settings.coachingVisible ? "on" : "off")")
                            Text("Tracking Ready: \(settings.trackingReady ? "yes" : "no")")
                        }
                        Text("Wall State: \(wallState)")
                        Text("Place Wall State: \(placeWallState)")
                        occlusionColorPicker
                        thresholdSlider
                    }
                    Spacer()
                }.padding([.top], 40)
                VStack {
                    Spacer()
                    VStack {
                        HStack {
                            placeBasePlaneButton
                            cancelAddWallButton
                        }
                        HStack {
                            updateBasePlaneButton
                            setFirstCornerButton
                            setSecondCornerButton
                        }
                    }.offset(y: 40)
                    VStack {
                        texturePicker
                        colorPicker
                    }
                }.padding([.bottom], 80)
            }
        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                settings.reset()
                settings.model.setColor(paint: activeColor, texture: activeTexture)
                // Uncomment this code to customize the UI images
                //            customizeColorTheme()
                setupBindings()
            }
        }
    }

    func customizeColorTheme() {
        if let gridImage = UIImage(named: "grid-WhiteAlt") {
            settings.model.setGridImage(gridImage: gridImage)
        }
        if let centerDotImage = UIImage(named: "centerDotAlt") {
            settings.model.setSwatchUIImages(cornerTextures: altCornerImages,
                                             centerDot: centerDotImage, 
                                             centerDotOuter: centerDotImage)
        }
    }
    
    func setupBindings() {
        settings.model.coachingVisible.sink { coachingVisible in
            settings.coachingVisible = coachingVisible
        }.store(in: &settings.model.cancellables)
        
        settings.model.trackingReady.sink { trackingReady in
            settings.trackingReady = trackingReady
        }.store(in: &settings.model.cancellables)
        
        settings.model.wallState.sink { wallState in
            settings.wallState = wallState
        }.store(in: &settings.model.cancellables)
        
        settings.model.placeWallState.sink { placeWallState in
            settings.placeWallState = placeWallState
        }.store(in: &settings.model.cancellables)
    }

    var arView: some View {
        RemodelARLib.makeARView(model: settings.model, arMethod: .Swatch)
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

    var placeBasePlaneButton: some View {
        Button(action: {
            settings.model.placeBasePlane()
        }, label: {
            Text("Place Plane")
                .bold()
                .foregroundColor(.white)
        })
            .padding()
            .background(Color(.sRGB, white: 0, opacity: 0.15))
            .cornerRadius(10)
    }

    var updateBasePlaneButton: some View {
        Button(action: {
            settings.model.updateBasePlane()
        }, label: {
            Text("Update Plane")
                .bold()
                .foregroundColor(.white)
        })
            .padding()
            .background(Color(.sRGB, white: 0, opacity: 0.15))
            .cornerRadius(10)
    }

    var setFirstCornerButton: some View {
        Button(action: {
            settings.model.setFirstCorner()
        }, label: {
            Text("Set UL")
                .bold()
                .foregroundColor(.white)
        })
            .padding()
            .background(Color(.sRGB, white: 0, opacity: 0.15))
            .cornerRadius(10)
    }

    var setSecondCornerButton: some View {
        Button(action: {
            settings.model.setSecondCorner()
        }, label: {
            Text("Set LR")
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

    var resetSceneButton: some View {
        Button(action: {
            settings.reset()
            settings.model.setColor(paint: activeColor, texture: activeTexture)
        },
               label: {
            Image("reset")
                .foregroundColor(.white)
        })
            .padding()
            .background(Color(.sRGB, white: 0, opacity: 0.15))
            .cornerRadius(10)
    }

    var wallState: String {
        switch settings.wallState {
        case .idle:
            return "idle"
        case .addingWall:
            return "addingWall"
        }
    }

    var placeWallState: String {
        switch settings.placeWallState {
        case .placingBasePlane:
            return "placingBasePlane"
        case .placingFirstCorner:
            return "placingFirstCorner"
        case .placingSecondCorner:
            return "placingSecondCorner"
        case .done:
            return "done"
        }
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
                    .background(
                        Color(
                            .sRGB,
                            white: 0,
                            opacity: settings.touchModeIndex == index ? 0.75 : 0.15
                        )
                    )
                    .cornerRadius(10)
            }
        }.offset(y: 40)
    }
}

private extension LegacyView {
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
                            .strokeBorder(
                                lineWidth: (settings.showStroke && i == settings.colorIndex) ? 5 : 0
                            )
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

private extension LegacyView {
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
    
    var altCornerImages: [Corners: UIImage] {
        guard let ulImage = UIImage(named: "upperLeftCornerAlt"),
              let urImage = UIImage(named: "upperRightCornerAlt"),
              let lrImage = UIImage(named: "lowerRightCornerAlt"),
              let llImage = UIImage(named: "lowerLeftCornerAlt")
        else { return [:] }
        return [
            Corners.upperLeftCorner: ulImage,
            Corners.upperRightCorner: urImage,
            Corners.lowerRightCorner: lrImage,
            Corners.lowerLeftCorner: llImage
        ]
    }
}

struct LegacyView_Previews: PreviewProvider {
    static var previews: some View {
        LegacyView()
    }
}
