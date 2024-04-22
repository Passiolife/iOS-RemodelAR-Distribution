//
//  Model.swift
//  Painty
//
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit
import RemodelAR

//MARK: - Color picker
struct ColorPicker {
    let color: WallPaint
    
    static var colors: [ColorPicker] {
        [
            ColorPicker(color: WallPaint(id: "0", name: "0", color: .orange)),
            ColorPicker(color: WallPaint(id: "1", name: "1", color: .red)),
            ColorPicker(color: WallPaint(id: "2", name: "2", color: .yellow)),
            ColorPicker(color: WallPaint(id: "3", name: "3", color: .green)),
            ColorPicker(color: WallPaint(id: "4", name: "4", color: .black)),
            ColorPicker(color: WallPaint(id: "5", name: "5", color: .blue)),
            ColorPicker(color: WallPaint(id: "7", name: "7", color: .brown)),
            ColorPicker(color: WallPaint(id: "8", name: "8", color: .lightGray)),
            ColorPicker(color: WallPaint(id: "9", name: "9", color: .darkGray)),
            ColorPicker(color: WallPaint(id: "10", name: "10", color: .systemPink)),
            ColorPicker(color: WallPaint(id: "11", name: "11", color: .purple)),
            ColorPicker(color: WallPaint(id: "12", name: "12", color: .cyan)),
            ColorPicker(color: WallPaint(id: "14", name: "14", color: .magenta)),
            ColorPicker(color: WallPaint(id: "15", name: "15", color: .gray))
        ]
    }
}

//MARK: - Texture picker
struct TexturePicker {
    let texture: String
    
    static var textures: [TexturePicker] {
        [
            TexturePicker(texture: "venetianWall"),
            TexturePicker(texture: "plasterWall"),
            TexturePicker(texture: "renaissanceWall"),
            TexturePicker(texture: "brickWall"),
            TexturePicker(texture: "cinderWall"),
            TexturePicker(texture: "pebbleWall"),
            TexturePicker(texture: "stoneWall")
        ]
    }
}
