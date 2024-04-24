//
//  PaintyView.swift
//  Painty
//
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import RemodelAR
import SwiftUI

struct PaintyView: View {
    @ObservedObject var model = ARStateModel()
    
    @State private var scanState: ScanState = .noMesh
    @State private var colorIndex = 0
    @State private var showStroke = true
    @State private var textureIndex = -1
    @State private var showTextureStroke = false
    
    var body: some View {
        ZStack {
            arView
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                scanButton
                if scanState == .painting {
                    HStack {
                        savePhotoButton
                        resetSceneButton
                    }
                    VStack(spacing: 0) {
                        texturePicker
                            .offset(y: 20)
                        colorPicker
                    }.padding(.bottom, 30)
                }
            }.padding(.bottom, 20)
        }
        .onAppear {
            model.toggleLidarOutline(visible: true)
            model.setLidarOutlineStyle(style: .shader(thickness: 10))
            model.setColor(paint: activeColor)
            model.startScene()
        }
    }
}

private extension PaintyView {
    var arView: some View {
        RemodelARLib.makeARView(model: model, arMethod: .Lidar)
            .modifier(DragActions(
                onDragStart: { point in
                    model.dragStart(point: point)
                }, onDragMove: { point in
                    model.dragMove(point: point)
                }, onDragEnd: { point in
                    model.dragEnd(point: point)
                })
            )
    }
    
    var activeColor: WallPaint {
        colorItems[colorIndex]
    }
    
    var activeTexture: UIImage? {
        if textureIndex < 0 {
            return nil
        }
        return textureImages[textureIndex]
    }
    
    var colorItems: [WallPaint] {
        let numHues = 20
        var colors = [WallPaint]()
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
            
            colors.append(WallPaint(id: "\(i * 4 + 1)", name: "\(i * 4 + 1)", color: color_8_8.uiColor()))
            colors.append(WallPaint(id: "\(i * 4 + 2)", name: "\(i * 4 + 2)", color: color_8_6.uiColor()))
            colors.append(WallPaint(id: "\(i * 4 + 3)", name: "\(i * 4 + 3)", color: color_8_4.uiColor()))
            colors.append(WallPaint(id: "\(i * 4 + 4)", name: "\(i * 4 + 4)", color: color_8_2.uiColor()))
        }
        return colors
    }
    
    var colorPicker: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(0..<colorItems.count, id: \.self) { i in
                    Button(action: {
                        showStroke = true
                        colorIndex = i
                        model.setColor(paint: activeColor, texture: activeTexture)
                    }, label: {
                        RoundedRectangle(cornerRadius: 17)
                            .strokeBorder(lineWidth: (showStroke && i == colorIndex) ? 5 : 0)
                            .foregroundColor(.white)
                            .background(Color(colorItems[i].color))
                            .clipShape(RoundedRectangle(cornerRadius: 17))
                            .frame(width: 74, height: 74)
                            .animation(.interpolatingSpring(stiffness: 60,
                                                            damping: 15),
                                       value: showStroke && i == colorIndex)
                    })
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
    var scanButton: some View {
        Button(action: {
            switch scanState {
            case .noMesh:
                scanState = .scanning
                model.setRenderMode(renderMode: .wireframe)
                model.startLidarScan()
                
            case .scanning:
                scanState = .painting
                model.setRenderMode(renderMode: .color)
                model.stopLidarScan()
                
            case .painting:
                scanState = .scanning
                model.setRenderMode(renderMode: .wireframe)
                model.startLidarScan()
            }
        }, label: {
            scanText
        })
        .padding()
        .background(Color(.sRGB, white: 0, opacity: 0.15))
        .cornerRadius(10)
    }
    
    var scanText: some View {
        switch scanState {
        case .noMesh, .painting:
            Text("Start Lidar")
            
        case .scanning:
            Text("Pause Lidar")
        }
    }
    
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
    
    var resetSceneButton: some View {
        Button(action: {
            colorIndex = 0
            textureIndex = -1
            scanState = .noMesh
            model.setColor(paint: activeColor)
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
                        model.setColor(
                            paint: activeColor,
                            texture: activeTexture
                        )
                    }, label: {
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
                            .animation(.interpolatingSpring(stiffness: 60,
                                                            damping: 15),
                                       value: showTextureStroke && i == textureIndex)
                    })
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

enum ScanState {
    case noMesh
    case scanning
    case painting
}
