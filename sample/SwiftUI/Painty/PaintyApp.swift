//
//  PaintyApp.swift
//  Painty
//
//  Copyright © 2022 Passio Inc. All rights reserved.
//

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
                PaintyView()
            case .techDemo:
                TechDemoView()
            }
        }
    }
}
