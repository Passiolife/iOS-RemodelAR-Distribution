//
//  TechDemoView.swift
//  Painty
//
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import ARKit
import Combine
import SwiftUI
import RemodelAR

final class SettingsData: ObservableObject {
    @Republished var model = ARStateModel()
    @Published var uiVisible = true
    @Published var tabSwitchingActive = true
    @Published var colorIndex = 0
    @Published var textureIndex: Int = -1
    @Published var showStroke = true
    @Published var showTextureStroke = false
    @Published var debugString = ""
    @Published var debugTimer: Timer?
    @Published var abModeIndex = 2
    @Published var touchModeIndex = 3
    @Published var occlusionThreshold: Double = 10
    @Published var scanMode: ScanMode = .paused
    @Published var unpaintedVisible = true
    @Published var coachingVisible = true
    @Published var trackingReady = false
    @Published var wallState: WallState = .idle
    @Published var placeWallState: PlaceWallState = .done
    @Published var floorplanState: FloorplanState = .noFloor
    @Published var planarMeshCount = 0
    @Published var numberOfFloorCorners = 0
    @Published var floorplanCornerMessage = ""
    
    func reset() {
        floorplanState = .noFloor
        numberOfFloorCorners = 0
        floorplanCornerMessage = ""
        uiVisible = true
        colorIndex = 0
        textureIndex = -1
        showStroke = true
        showTextureStroke = false
        debugString = ""
        debugTimer?.invalidate()
        debugTimer = nil
        abModeIndex = 2
        touchModeIndex = 3
        occlusionThreshold = 10
        scanMode = .paused
        unpaintedVisible = true
        coachingVisible = true
        trackingReady = false
        wallState = .idle
        placeWallState = .done
        planarMeshCount = 0
        model.resetScene()
    }
}

struct TechDemoView: View {
    @State var currentTab = 0
    @StateObject var settings = SettingsData()
    
    var body: some View {
        ZStack {
            Color.backgroundColor
                .edgesIgnoringSafeArea(.all)
            if currentTab == 0 {
                if supportsLidar {
                    LidarView()
                } else {
                    Text("Lidar not supported on this device")
                        .foregroundColor(.textColor)
                }
            } else if currentTab == 1 {
                LegacyView()
            } else if currentTab == 2 {
                FloorplanView()
            } else if currentTab == 3 {
                ShaderPaintView()
            } else if currentTab == 4 {
                if supportsLidar {
                    AbnormalitiesView()
                } else {
                    Text("Lidar not supported on this device")
                        .foregroundColor(.textColor)
                }
            }
            if settings.uiVisible {
                VStack {
                    Spacer()
                    viewModePicker
                }
            }
            VStack {
                HStack {
                    Spacer()
                    uiVisibleButton
                        .padding(.trailing, 10)
                        .padding(.top, 42)
                }
                Spacer()
            }
        }
        .environmentObject(settings)
        .edgesIgnoringSafeArea(.all)
    }
    
    var supportsLidar: Bool {
        ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
    }
    
    var uiVisibleButton: some View {
        Button(action: {
            settings.uiVisible.toggle()
        }, label: {
            Image(systemName: settings.uiVisible ? "eye.fill" : "eye.slash.fill")
                .foregroundColor(.white)
        })
            .padding()
            .background(Color(.sRGB, white: 0, opacity: 0.15))
            .cornerRadius(10)
    }
    
    var viewModePicker: some View {
        let modes = ["Lidar", "Legacy", "Floorplan", "Shader", "Defects"]
        return HStack(spacing: 5) {
            ForEach(0..<modes.count, id: \.self) {
                let index = $0
                let mode = modes[index]
                Button(action: {
                    currentTab = index
                    if !supportsLidar,
                       mode == "Lidar" || mode == "Defects" {
                        return
                    } else {
                        settings.tabSwitchingActive = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            settings.tabSwitchingActive = true
                        }
                    }
                },
                       label: {
                    VStack(spacing: 3) {
                        Image("\(modes[index].lowercased())")
                        Text("\(mode)")
                            .bold()
                            .font(.system(size: 12))
                    }.foregroundColor(settings.tabSwitchingActive ? .white : .gray)
                })
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding(10)
                    .background(Color(.sRGB, white: 0, opacity: currentTab == index ? 0.75 : 0.15))
                    .cornerRadius(10)
            }
        }
        .padding([.leading, .trailing], 10)
        .padding([.top, .bottom], 20)
        .disabled(!settings.tabSwitchingActive)
    }
}

struct TechDemoView_Previews: PreviewProvider {
    static var previews: some View {
        TechDemoView()
    }
}
