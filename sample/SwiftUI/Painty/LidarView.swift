//
//  LidarView.swift
//  RemodelAR-Demo
//
//  Copyright © 2021 Passio Inc. All rights reserved.
//

import ARKit
import Combine
import SwiftUI
import RemodelAR

struct LidarView: View {
    var cancellables = Set<AnyCancellable>()
    @ObservedObject var model = ARStateModel()

    @State private var colorIndex = 0
    @State private var textureIndex = -1
    @State private var showStroke = true
    @State private var showTextureStroke = false
    @State private var debugString = ""
    @State private var debugTimer: Timer?
    @State private var touchModeIndex = 3
    @State private var occlusionThreshold: Double = 10
    
    init() {

    }
    
    var body: some View {
        ZStack {
            ZStack(alignment: .bottom, content: {
                arView
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        savePhotoButton
                        save3DModelButton
                        resetSceneButton
                        getPaintInfoButton
                    }
                    if !debugString.isEmpty {
                        debugText
                    }
                    Text("Planar Meshes: \(model.planarMeshCount)")
                    Spacer()
                    VStack(spacing: 0) {
                        texturePicker
                            .offset(y: 20)
                        colorPicker
                    }.padding(.bottom, 30)
                }
            })
        }
        .onAppear {
            model.pickColor(paint: colorItems[0])
            setupBindings()
        }
    }
    
    var arView: ARView {
        RemodelARLib.makeARView(model: model, arMethod: .Lidar)
    }
    
    func setupBindings() {
        model.$paintInfo.sink { [self] paintInfo in
            guard let paintInfo = paintInfo else { return }
            var output = [String]()
            for (_, wall) in paintInfo.paintedWalls.enumerated() {
                output.append("\(wall.area.width.formatted())x\(wall.area.height.formatted()) (\(wall.area.area.formatted()))")
                output.append("estimated: \(wall.area.estimatedActualArea.formatted()) m²")
            }
            debugString = output.joined(separator: "\n")
        }.store(in: &model.cancellables)
    }
}

private extension LidarView {
    var colorItems: [WallPaint] {
        let numHues = 20
        var colors = [WallPaint]()
        colors.append(WallPaint(id: "0", color: Color(red: 230.0/255.0, green: 224.0/255.0, blue: 200.0/255.0).uiColor()))
        colors.append(WallPaint(id: "0", color: Color(red: 220.0/255.0, green: 195.0/255.0, blue: 235.0/255.0).uiColor()))
        colors.append(WallPaint(id: "0", color: Color(red: 252.0/255.0, green: 247.0/255.0, blue: 235.0/255.0).uiColor()))
        colors.append(WallPaint(id: "0", color: Color(red: 255.0/255.0, green: 255.0/255.0, blue: 251.0/255.0).uiColor()))
        colors.append(WallPaint(id: "0", color: Color(red: 58.0/255.0, green: 59.0/255.0, blue: 61.0/255.0).uiColor()))
        colors.append(WallPaint(id: "0", color: Color(red: 101.0/255.0, green: 118.0/255.0, blue: 134.0/255.0).uiColor()))
        colors.append(WallPaint(id: "0", color: Color(red: 239.0/255.0, green: 234.0/255.0, blue: 196.0/255.0).uiColor()))
        colors.append(WallPaint(id: "0", color: Color(red: 125.0/255.0, green: 83.0/255.0, blue: 68.0/255.0).uiColor()))
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
                        model.pickColor(paint: colorItems[i])
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

private extension LidarView {
    var debugText: some View {
        VStack(alignment: .center, spacing: nil, content: {
            Text(debugString)
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
            model.sharePhoto()
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
        Button(action: { model.save3DModel() }, label: {
            Image("saveMesh")
                .foregroundColor(.white)
        })
        .padding()
        .background(Color(.sRGB, white: 0, opacity: 0.15))
        .cornerRadius(10)
    }
    
    var resetSceneButton: some View {
        Button(action: { model.resetScene() },
               label: {
                Image("reset")
                    .foregroundColor(.white)
               })
        .padding()
        .background(Color(.sRGB, white: 0, opacity: 0.15))
        .cornerRadius(10)
    }
    
    var getPaintInfoButton: some View {
        Button(action: { model.getPaintInfo() },
               label: {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.white)
               })
        .padding()
        .background(Color(.sRGB, white: 0, opacity: 0.15))
        .cornerRadius(10)
    }
    
    func showDebugMessage(message: String) {
        debugString = message
        debugTimer?.invalidate()
        debugTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { _ in
            debugString = ""
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
                    Button(action: {
                        if i == textureIndex {
                            showTextureStroke = false
                            textureIndex = -1
                            model.pickTexture(texture: nil)
                        } else {
                            showTextureStroke = true
                            textureIndex = i
                            model.pickTexture(texture: textureImages[i])
                        }
                    }) {
                        RoundedRectangle(cornerRadius: 17)
                            .strokeBorder(lineWidth: (showTextureStroke && i == textureIndex) ? 5 : 0)
                            .foregroundColor(.white)
                            .background(Image(uiImage: textureImages[i]))
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
        }
    }
}

struct LidarView_Previews: PreviewProvider {
    static var previews: some View {
        LidarView()
    }
}
