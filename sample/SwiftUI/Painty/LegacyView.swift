//
//  LegacyView.swift
//  RemodelAR-Demo
//
//  Copyright © 2021 Passio Inc. All rights reserved.
//

import ARKit
import Combine
import SwiftUI
import RemodelAR

struct LegacyView: View {
    @State private var colorIndex = 0
    @State private var textureIndex = -1
    @State private var showStroke = true
    @State private var showTextureStroke = false
    @EnvironmentObject var settings: SettingsData
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                arView
                    .edgesIgnoringSafeArea(.all)
                if settings.uiVisible {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            centerDot
                            Spacer()
                        }
                        Spacer()
                    }
                    VStack {
                        VStack {
                            HStack {
                                savePhotoButton
                                resetSceneButton
                            }
                            HStack {
                                Text("Coaching: \(settings.model.coachingVisible ? "on" : "off")")
                                Text("Tracking Ready: \(settings.model.trackingReady ? "yes" : "no")")
                            }
                            Text("Wall State: \(wallState)")
                            Text("Place Wall State: \(placeWallState)")
                        }
                        if !settings.debugString.isEmpty {
                            debugText
                        }
                        Spacer()
                    }
                    VStack {
                        Spacer()
                        VStack {
                            HStack {
                                addWallButton
                                placeBasePlaneButton
                                cancelAddWallButton
                            }
                            HStack {
                                updateBasePlaneButton
                                setUpperLeftCornerButton
                                setLowerRightCornerButton
                            }
                        }.offset(y: 40)
                        VStack {
                            texturePicker
                            colorPicker
                        }
                    }.offset(y: -60)
                }
            }.onAppear {
                settings.model.pickColor(paint: colorItems[colorIndex])
                settings.model.setScanPoint(
                    point: CGPoint(x: geometry.size.width / 2,
                                   y: geometry.size.height / 2)
                )
            }
        }
    }
    
    var arView: some View {
        RemodelARLib.makeARView(model: settings.model, arMethod: .Legacy)
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
    
    func setupBindings() {
        settings.model.$trackingReady.sink { ready in
            print("Ready: \(ready ? "yes" : "no")")
        }.store(in: &settings.model.cancellables)
    }
}

private extension LegacyView {
    var centerDot: some View {
        ZStack {
            Circle()
                .fill(Color(.sRGB, white: 0, opacity: 0.2))
                .frame(width: 80, height: 80)
                .overlay(
                    Circle()
                        .strokeBorder(Color.blue, lineWidth: 2, antialiased: true)
                )
            Circle()
                .fill(Color.blue)
                .frame(width: 20, height: 20)
        }
    }
    
    var addWallButton: some View {
        Button(action: {
            settings.model.addWall()
        }, label: {
            Text("Add Wall")
                .bold()
                .foregroundColor(.white)
        })
        .padding()
        .background(Color(.sRGB, white: 0, opacity: 0.15))
        .cornerRadius(10)
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
    
    var setUpperLeftCornerButton: some View {
        Button(action: {
            settings.model.setUpperLeftCorner()
        }, label: {
            Text("Set UL")
                .bold()
                .foregroundColor(.white)
        })
        .padding()
        .background(Color(.sRGB, white: 0, opacity: 0.15))
        .cornerRadius(10)
    }
    
    var setLowerRightCornerButton: some View {
        Button(action: {
            settings.model.setLowerRightCorner()
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
            showDebugMessage(message: "Image Saved!")
        }, label: {
            Image(systemName: "camera.fill")
                .foregroundColor(.white)
        })
        .padding()
        .background(Color(.sRGB, white: 0, opacity: 0.15))
        .cornerRadius(10)
    }
    
    var resetSceneButton: some View {
        Button(action: { settings.model.resetScene() },
               label: {
                Image("reset")
                    .foregroundColor(.white)
               })
        .padding()
        .background(Color(.sRGB, white: 0, opacity: 0.15))
        .cornerRadius(10)
    }
    
    var wallState: String {
        switch settings.model.wallState {
        case .idle:
            return "idle"
        case .addingWall:
            return "addingWall"
        @unknown default:
            return ""
        }
    }
    
    var placeWallState: String {
        switch settings.model.placeWallState {
        case .placingBasePlane:
            return "placingBasePlane"
        case .placingUpperLeftCorner:
            return "placingUpperLeftCorner"
        case .placingBottomRightCorner:
            return "placingBottomRightCorner"
        case .done:
            return "done"
        @unknown default:
            return ""
        }
    }
}

private extension LegacyView {
    var colorItems: [WallPaint] {
        let numHues = 20
        var colors = [WallPaint]()
        colors.append(WallPaint(id: "0", color: Color(red: 230.0/255.0, green: 224.0/255.0, blue: 200.0/255.0).uiColor()))
        for i in 0..<numHues {
            let color_8_8 = Color(hue: Double(i)/Double(numHues),
                                  saturation: 0.8,
                                  brightness: 0.8)
            let color_8_6 = Color(hue: Double(i)/Double(numHues),
                                  saturation: 0.8,
                                  brightness: 0.6)
            let color_8_4 = Color(hue: Double(i)/Double(numHues),
                                  saturation: 0.8,
                                  brightness: 0.4)
            let color_8_2 = Color(hue: Double(i)/Double(numHues),
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
                    Button(action: {
                        showStroke = true
                        colorIndex = i
                        settings.model.pickColor(paint: colorItems[i])
                    }) {
                        RoundedRectangle(cornerRadius: 17)
                            .strokeBorder(lineWidth: (showStroke && i == colorIndex) ? 5 : 0)
                            .foregroundColor(.white)
                            .background(Color(colorItems[i].color))
                            .clipShape(RoundedRectangle(cornerRadius: 17))
                            .frame(width: 74, height: 74)
                            .animation(Animation.interpolatingSpring(stiffness: 60, damping: 15))
                    }
                    .onTapGesture {
                        self.showStroke = true
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
                    Button(action: {
                        if i == textureIndex {
                            showTextureStroke = false
                            textureIndex = -1
                            settings.model.pickTexture(texture: nil)
                        } else {
                            showTextureStroke = true
                            textureIndex = i
                            settings.model.pickTexture(texture: textureImages[i])
                        }
                    }) {
                        RoundedRectangle(cornerRadius: 17)
                            .strokeBorder(lineWidth: (showTextureStroke && i == textureIndex) ? 5 : 0)
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
                        self.showTextureStroke.toggle()
                    }
                }
            }
            .padding()
        }.offset(y: 30)
    }
}

struct LegacyView_Previews: PreviewProvider {
    static var previews: some View {
        LegacyView()
    }
}
