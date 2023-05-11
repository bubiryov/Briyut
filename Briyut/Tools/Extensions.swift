//
//  Extetnsions.swift
//  Briyut
//
//  Created by Egor Bubiryov on 03.05.2023.
//

import Foundation
import SwiftUI

typealias ScreenSize = CGFloat

extension ScreenSize {
    static var height: ScreenSize {
        return UIScreen.main.bounds.height
    }
    static var width: ScreenSize {
        return UIScreen.main.bounds.width
    }
}

extension Color {
    static let mainColor = Color("MainColor")
    static let secondaryColor = Color("SecondaryColor")
    static let darkColor = Color("DarkColor")
    static let lightBlueColor = Color("LightBlueColor")
}

func bottonPadding() -> CGFloat {
    if ScreenSize.height < 750 {
        return ScreenSize.height * 0.02
    } else {
        return ScreenSize.height * 0.035
    }
}

func topPadding() -> CGFloat {
    if ScreenSize.height < 750 {
        return ScreenSize.height * 0.015
    } else {
        return 0
    }
}

func tabBarHeight() -> CGFloat {
    if ScreenSize.height < 750 {
        return (ScreenSize.width / 15) + 45
    } else {
        return (ScreenSize.width / 15) + 30
    }
}


