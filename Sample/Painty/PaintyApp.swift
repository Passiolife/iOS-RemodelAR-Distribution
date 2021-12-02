//
//  PaintyApp.swift
//  Painty
//
//  Copyright © 2021 Passio Inc. All rights reserved.
//

import SwiftUI

enum RunMode {
    case painty
    case lidar
    case legacy
    case shaderPaint
}

@main
struct PaintyApp: App {
    
    var runMode: RunMode = .legacy
    
    var body: some Scene {
        WindowGroup {
            switch runMode {
            case .painty:
                PaintyView()
            case .lidar:
                LidarView()
            case .legacy:
                LegacyView()
            case .shaderPaint:
                ShaderPaintView()
            }
        }
    }
}
