//
//  PaintyView.swift
//  Painty
//
//  Copyright © 2021 Passio Inc. All rights reserved.
//

import RemodelAR
import SwiftUI

struct PaintyView: View {
    @StateObject var model = ARStateModel()
    
    @State private var colorIndex = 0
    @State private var showStroke = true
    @State private var textureIndex = -1
    @State private var showTextureStroke = false
    
    var body: some View {
        ZStack {
            ZStack(alignment: .bottom, content: {
                arView
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    HStack {
                        savePhotoButton
                        save3DModelButton
                        resetSceneButton
                    }
                    VStack(spacing: 0) {
                        texturePicker
                            .offset(y: 20)
                        colorPicker
                    }.padding(.bottom, 30)
                }.padding(.bottom, -20)
            })
        }
        .onAppear {
            model.pickColor(paint: colorItems[0])
        }
    }
}

private extension PaintyView {
    var arView: ARView {
        RemodelARLib.makeARView(model: model, arMethod: .Lidar)
    }

    var colorItems: [WallPaint] {
        let numHues = 20
        var colors = [WallPaint]()
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
            
            colors.append(WallPaint(id: "\(i * 4 + 1)", color: color_8_8.uiColor()))
            colors.append(WallPaint(id: "\(i * 4 + 2)", color: color_8_6.uiColor()))
            colors.append(WallPaint(id: "\(i * 4 + 3)", color: color_8_4.uiColor()))
            colors.append(WallPaint(id: "\(i * 4 + 4)", color: color_8_2.uiColor()))
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

private extension PaintyView {
    var savePhotoButton: some View {
        Button(action: {
            model.sharePhoto()
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
            model.save3DModel()
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
            model.resetScene()
        }, label: {
            Image("reset")
                .foregroundColor(.white)
        })
        .padding()
        .background(Color(.sRGB, white: 0, opacity: 0.15))
        .cornerRadius(10)
    }
}

private extension PaintyView {
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

struct PaintyView_Previews: PreviewProvider {
    static var previews: some View {
        PaintyView()
    }
}
