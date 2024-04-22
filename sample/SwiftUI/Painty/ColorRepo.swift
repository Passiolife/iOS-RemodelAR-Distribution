//
//  ColorRepo.swift
//  Painty
//
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import Foundation
import UIKit

enum ColorRepo {
    public static func colors() -> [UIColor] {
        let numHues = 20
        var colors = [UIColor]()
        
        for i in 0..<numHues {
            let color_8_8 = UIColor.HSL(hue: 360.0 * Double(i) / Double(numHues),
                                        saturation: 60,
                                        lightness: 80)
            let color_8_6 = UIColor.HSL(hue: 360.0 * Double(i) / Double(numHues),
                                        saturation: 70,
                                        lightness: 60)
            let color_8_4 = UIColor.HSL(hue: 360.0 * Double(i) / Double(numHues),
                                        saturation: 70,
                                        lightness: 40)
            let color_8_2 = UIColor.HSL(hue: 360.0 * Double(i) / Double(numHues),
                                        saturation: 70,
                                        lightness: 20)

            colors.append(UIColor(color_8_8))
            colors.append(UIColor(color_8_6))
            colors.append(UIColor(color_8_4))
            colors.append(UIColor(color_8_2))
        }

        return colors
    }
}
