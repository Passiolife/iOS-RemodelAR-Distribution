//
//  Model.swift
//  iOS-AR-Remodel-Module-UIKit
//
//  Created by mac-0002 on 03/12/21.
//

import UIKit
import RemodelAR

//MARK: - Color picker
struct ColorPicker {
    let color: WallPaint
}

let colorPicker = [ColorPicker(color: WallPaint(id: "0", color: .orange)),
                   ColorPicker(color: WallPaint(id: "1", color: .red)),
                   ColorPicker(color: WallPaint(id: "2", color: .yellow)),
                   ColorPicker(color: WallPaint(id: "3", color: .green)),
                   ColorPicker(color: WallPaint(id: "4", color: .black)),
                   ColorPicker(color: WallPaint(id: "5", color: .blue)),
                   ColorPicker(color: WallPaint(id: "7", color: .brown)),
                   ColorPicker(color: WallPaint(id: "8", color: .lightGray)),
                   ColorPicker(color: WallPaint(id: "9", color: .darkGray)),
                   ColorPicker(color: WallPaint(id: "10", color: .systemPink)),
                   ColorPicker(color: WallPaint(id: "11", color: .purple)),
                   ColorPicker(color: WallPaint(id: "12", color: .cyan)),
                   ColorPicker(color: WallPaint(id: "14", color: .magenta)),
                   ColorPicker(color: WallPaint(id: "15", color: .gray))]


//MARK: - Texture picker
struct TexturePicker {
    let texture: String
}

let texturePicker = [TexturePicker(texture: "ChalkPaints"),
                     TexturePicker(texture: "ConcreteEffects1"),
                     TexturePicker(texture: "ConcreteEffects2"),
                     TexturePicker(texture: "Corium"),
                     TexturePicker(texture: "Ebdaa"),
                     TexturePicker(texture: "Elora"),
                     TexturePicker(texture: "Glostex"),
                     TexturePicker(texture: "GraniteArenal"),
                     TexturePicker(texture: "Khayal_Beauty 010"),
                     TexturePicker(texture: "Marmo"),
                     TexturePicker(texture: "Texture"),
                     TexturePicker(texture: "Tourmaline"),
                     TexturePicker(texture: "Worood")]
