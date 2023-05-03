//
//  Extetnsions.swift
//  Briyut
//
//  Created by Egor Bubiryov on 03.05.2023.
//

import Foundation
import SwiftUI

typealias ScreenHeight = CGFloat

extension ScreenHeight {
    static var main: ScreenHeight {
        return UIScreen.main.bounds.height
    }
}

