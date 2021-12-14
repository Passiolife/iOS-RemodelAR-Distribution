//
//  ShaderPaintView.swift
//  RemodelAR-Demo
//
//  Copyright © 2021 Passio Inc. All rights reserved.
//

import ARKit
import Combine
import SwiftUI
import RemodelAR

struct ShaderPaintView: View {
    @State private var colorIndex = 0
    @State private var textureIndex = -1
    @State private var showStroke = true
    @State private var showTextureStroke = false
    @State private var abModeIndex = 2
    @State private var touchModeIndex = 3
    @State private var occlusionThreshold: Double = 10
    @EnvironmentObject var settings: SettingsData
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                arView
                    .edgesIgnoringSafeArea(.all)
                if settings.uiVisible {
                    if abModeIndex == 0 {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                centerDot
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                    VStack {
                        HStack {
                            savePhotoButton
                            resetSceneButton
                        }
                        if !settings.debugString.isEmpty {
                            debugText
                        }
                        Spacer()
                    }
                    VStack {
                        Spacer()
                        VStack {
                            thresholdSlider
                            abModePicker
                            touchModePicker
                        }.offset(y: -30)
                        colorPicker
                    }.offset(y: -60)
                }
            }.onAppear {
                settings.model.pickColor(paint: colorItems[colorIndex])
                settings.model.setTouchMode(mode: TouchMode(rawValue: touchModeIndex)!)
            }
        }
    }
    
    var arView: some View {
        RemodelARLib.makeARView(model: settings.model, arMethod: .ShaderPainting)
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
}

private extension ShaderPaintView {
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
    
    var thresholdSlider: some View {
        Slider(value: $occlusionThreshold, in: 4...30)
            .padding()
            .valueChanged(value: occlusionThreshold) { threshold in
                settings.model.setColorThreshold(threshold: Float(threshold))
            }.offset(y: 40)
    }
    
    var resetSceneButton: some View {
        Button(action: {
            settings.model.resetScene()
            showDebugMessage(message: "Scene reset!")
        },
               label: {
            Image("reset")
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
    
    var abModePicker: some View {
        let modes = ["Record", "Stop", "Idle"]
        return HStack(spacing: 2) {
            ForEach(0..<modes.count, id: \.self) {
                let index = $0
                let mode = modes[index]
                Button(action: {
                    settings.model.setTestingMode(mode: index)
                    abModeIndex = index
                },
                       label: {
                    Text("\(mode)")
                        .bold()
                        .foregroundColor(.white)
                })
                    .padding(17)
                    .background(Color(.sRGB, white: 0, opacity: abModeIndex == index ? 0.75 : 0.15))
                    .cornerRadius(10)
            }
        }.offset(y: 40)
    }
    
    var touchModePicker: some View {
        let modes = ["Average", "Dark", "Light", "Brightness"]
        return HStack(spacing: 5) {
            ForEach(0..<modes.count, id: \.self) {
                let index = $0
                let mode = modes[index]
                Button(action: {
                    settings.model.setTouchMode(mode: TouchMode(rawValue: index)!)
                    touchModeIndex = index
                },
                       label: {
                    Text("\(mode)")
                        .bold()
                        .foregroundColor(.white)
                })
                    .padding(EdgeInsets(top: 17, leading: 12, bottom: 17, trailing: 12))
                    .background(Color(.sRGB, white: 0, opacity: touchModeIndex == index ? 0.75 : 0.15))
                    .cornerRadius(10)
            }
        }.offset(y: 40)
    }
}

private extension ShaderPaintView {
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

private extension ShaderPaintView {
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
        }
    }
}

struct ShaderPaint_Previews: PreviewProvider {
    static var previews: some View {
        ShaderPaintView()
    }
}

extension View {
    /// A backwards compatible wrapper for iOS 14 `onChange`
    @ViewBuilder func valueChanged<T: Equatable>(value: T, onChange: @escaping (T) -> Void) -> some View {
        if #available(iOS 14.0, *) {
            self.onChange(of: value, perform: onChange)
        } else {
            self.onReceive(Just(value)) { (value) in
                onChange(value)
            }
        }
    }
}
