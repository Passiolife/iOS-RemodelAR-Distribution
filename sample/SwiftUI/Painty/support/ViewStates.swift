//
//  ViewStates.swift
//  Painty
//
//  Created by Davido Hyer on 4/23/24.
//

import Foundation

enum RoomPlanViewMode {
    case initializing
    case scanning
    case reviewing
    case painting
    case editingPatches
    case creatingPatch
}

enum SwatchViewMode {
    case editingWalls
    case editingPatches
    case creatingWall
    case creatingPatch
}

struct ARMethod {
    let name: String
    let imageName: String
}
