//
//  PaintyApp.swift
//  Painty
//
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import ARKit
import RemodelAR
import SwiftUI

/// Enum that determines which view to run the app with
///
/// Options
/// - painty - The final demo app created by following the tutorials.
/// - lidar - Uses Lidar to paint the room with automatic occlusions.
/// - legacy - User manually places a square mesh on the wall.
/// - shaderPaint - User selects colors on the wall to determine which objects are removed from painting as occlusions, works best with even, diffuse lighting and high contrast wall colors.
enum RunMode {
    case paintyDemo
    case techDemo
}

@main
struct PaintyApp: App {
    
    var runMode: RunMode = .techDemo
    
    var body: some Scene {
        WindowGroup {
            switch runMode {
            case .paintyDemo:
                if supportsLidar {
                    PaintyView()
                } else {
                    Text("Lidar not supported on this device")
                        .foregroundColor(.textColor)
                }
            case .techDemo:
                TechDemoView()
            }
        }
    }
    
    var supportsLidar: Bool {
        ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
    }
    
    init() {
        // Replace "license_key" with your license key
        PassioConfiguration.configure(license: "1dGgdRPbsWTP4LVLmcbS0LPGukZ6hChF7TnJXtZjyL7C",
                                      releaseMode: .development)
    }
}
