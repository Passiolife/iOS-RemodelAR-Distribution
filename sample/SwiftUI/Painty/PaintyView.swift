//
//  PaintyView.swift
//  Painty
//
//  Copyright © 2022 Passio Inc. All rights reserved.
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
            model.setColor(paint: activeColor, texture: activeTexture)
        }
    }
}

private extension PaintyView {
    var arView: ARView {
        RemodelARLib.makeARView(model: model, arMethod: .Lidar)
    }

    var activeColor: WallPaint {
        colorItems[colorIndex]
    }
    
    var activeTexture: UIImage? {
        guard textureIndex >= 0
        else { return nil }
        
        return textureImages[textureIndex]
    }
    
    var colorItems: [WallPaint] {
        ColorRepo.colors().enumerated().map({ WallPaint(id: "\($0.offset)",
                                                        name: "\($0.offset)",
                                                        color: $0.element) })
    }

    var colorPicker: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(0..<colorItems.count, id: \.self) { i in
                    Button(action: {
                        showStroke = true
                        colorIndex = i
                        model.setColor(paint: activeColor, texture: activeTexture)
                    }) {
                        RoundedRectangle(cornerRadius: 17)
                            .strokeBorder(lineWidth: (showStroke && i == colorIndex) ? 5 : 0)
                            .foregroundColor(.white)
                            .background(Color(colorItems[i].color))
                            .clipShape(RoundedRectangle(cornerRadius: 17))
                            .frame(width: 74, height: 74)
                            .animation(.interpolatingSpring(stiffness: 60, damping: 15),
                                       value: showStroke && i == colorIndex)
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
                    Button(action: {
                        if i == textureIndex {
                            showTextureStroke = false
                            textureIndex = -1
                        } else {
                            showTextureStroke = true
                            textureIndex = i
                        }
                        model.setColor(paint: activeColor, texture: activeTexture)
                    }) {
                        RoundedRectangle(cornerRadius: 17)
                            .strokeBorder(lineWidth: (showTextureStroke && i == textureIndex) ? 5 : 0)
                            .foregroundColor(.white)
                            .background(
                                Image(uiImage: textureImages[i])
                                    .resizable()
                                    .frame(width: 200, height: 200)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 17))
                            .frame(width: 74, height: 74)
                            .animation(.interpolatingSpring(stiffness: 60, damping: 15),
                                       value: showStroke && i == colorIndex)
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
