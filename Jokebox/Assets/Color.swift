//
//  Color.swift
//  Jokester
//
//  Created by Sohum Berry on 6/7/23.
//

import Foundation
import SwiftUI

extension Color {
    static let theme = ColorTheme()
    
    static let lightShadow = Color(red: 215 / 255, green: 215 / 255, blue: 215 / 255)
    static let darkShadow = Color(red: 163 / 255, green: 177 / 255, blue: 198 / 255)
    static let background = Color("bg")
    static let neumorphictextColor = Color(red: 132 / 255, green: 132 / 255, blue: 132 / 255)
}

struct ColorTheme {
    let bg = Color("bg")
    let fg = Color("fg")
    let accent = Color("accent")
    let black = Color("black")
    let gray = Color("gray")
    let fg_dull = Color("fg_dull")
    let light_gray = Color("light_gray")
}
