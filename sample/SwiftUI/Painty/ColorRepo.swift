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

        colors.append(UIColor(red: 239,
                              green: 234,
                              blue: 196,
                              opacity: 255))
        colors.append(UIColor(red: 230,
                              green: 224,
                              blue: 200,
                              opacity: 255))
        colors.append(UIColor(red: 252,
                              green: 247,
                              blue: 235,
                              opacity: 255))
        colors.append(UIColor(red: 255,
                              green: 255,
                              blue: 251,
                              opacity: 255))
        colors.append(UIColor(red: 204,
                              green: 204,
                              blue: 200,
                              opacity: 255))
        colors.append(UIColor(red: 220,
                              green: 195,
                              blue: 235,
                              opacity: 255))
        colors.append(UIColor(red: 125,
                              green: 83,
                              blue: 68,
                              opacity: 255))
        colors.append(UIColor(red: 73,
                              green: 95,
                              blue: 75,
                              opacity: 255))
        colors.append(UIColor(red: 101,
                              green: 118,
                              blue: 134,
                              opacity: 255))
        colors.append(UIColor(red: 58,
                              green: 59,
                              blue: 61,
                              opacity: 255))
        colors.append(UIColor(red: 47,
                              green: 13,
                              blue: 12,
                              opacity: 255))
        
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
