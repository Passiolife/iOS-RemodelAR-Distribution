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
                VStack {
                    Spacer()
                    VStack {
                        HStack {
                            finishCornersButton
                            finishHeightButton
                            cancelAddWallButton
                        }
                    }.offset(y: 40)
                    VStack {
                        texturePicker
                        colorPicker
                    }
                }.padding([.bottom], 80)
            }
        }.onAppear {
            settings.reset()
            settings.model.pickColor(paint: colorItems[settings.colorIndex])
            setupBindings()
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
        }.store(in: &settings.model.cancellables)
    }
    
    var arView: some View {
        RemodelARLib.makeARView(model: settings.model, arMethod: .Floorplan)
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
    
    var finishCornersButton: some View {
        Button(action: {
            settings.model.finishCorners(closeShape: false)
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
        Button(action: { settings.model.getPaintInfo() },
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
        ColorRepo.colors().map({ WallPaint(id: "0", color: $0) })
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

private extension FloorplanView {
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
                            .background(
                                Image(uiImage: textureImages[i])
                                    .renderingMode(.original)
                            )
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

struct FloorplanView_Previews: PreviewProvider {
    static var previews: some View {
        FloorplanView()
    }
}
