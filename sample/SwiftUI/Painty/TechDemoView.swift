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
    @Published var depthThreshold: Double = 0.05
    @Published var lidarOcclusionScanActive = false
    @Published var occlusionThreshold: Double = 10
    @Published var swatchViewMode: SwatchViewMode = .editingWalls
    @Published var scanMode: ScanMode = .paused
    @Published var unpaintedVisible = true
    @Published var coachingVisible = true
    @Published var trackingReady = false
    @Published var currentSelectedWallId: UUID?
    @Published var isEditModeActive = false
    @Published var isEditPatchSelected = false
    @Published var wallState: WallState = .idle
    @Published var placeWallState: PlaceWallState = .done
    @Published var floorplanState: FloorplanState = .noFloor
    @Published var planarMeshCount = 0
    @Published var numberOfFloorCorners = 0
    @Published var floorplanCornerMessage = ""
    @Published var roomPlanViewMode: RoomPlanViewMode = .initializing
    @Published var roomPlanInstruction = ""
    @Published var contextSwitchDelay = DispatchTimeInterval.milliseconds(100)
    
    func modeSwitched() {
        model.cancellables.forEach { cancellable in
            cancellable.cancel()
        }
        model.cancellables.removeAll()
    }
    
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
                if supportsLidar,
                   #available(iOS 16, *) {
                    RoomPlanView()
                } else {
                    Text("RoomPlan not supported on this device")
                        .foregroundColor(.textColor)
                }
            } else if currentTab == 1 {
                if supportsLidar {
                    LidarView()
                } else {
                    Text("Lidar not supported on this device")
                        .foregroundColor(.textColor)
                }
            } else if currentTab == 2 {
                LegacyView()
            } else if currentTab == 3 {
                FloorplanView()
            } else if currentTab == 4 {
                ShaderPaintView()
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
        let modes = [
            ARMethod(name: "Room Plan", imageName: "roomplan"),
            ARMethod(name: "Lidar", imageName: "lidar"),
            ARMethod(name: "Legacy", imageName: "legacy"),
            ARMethod(name: "Floor Plan", imageName: "floorplan"),
            ARMethod(name: "Shader", imageName: "shader")
        ]
        return HStack(spacing: 5) {
            ForEach(0..<modes.count, id: \.self) {
                let index = $0
                let mode = modes[index]
                Button(action: {
                    currentTab = index
                    if !supportsLidar,
                       mode.name == "Lidar" || mode.name == "Room Plan" {
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
                        Image("\(mode.imageName)")
                        Text("\(mode.name)")
                            .bold()
                            .font(.system(size: 12))
                        Spacer()
                    }.foregroundColor(settings.tabSwitchingActive ? .white : .gray)
                })
                .frame(width: 60, height: 65)
                .padding([.top], 12)
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
