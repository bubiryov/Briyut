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

func bottomPadding() -> CGFloat {
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
        return 5
    }
}

func tabBarHeight() -> CGFloat {
    if ScreenSize.height < 750 {
        return (ScreenSize.width / 15) + 45
    } else {
        return (ScreenSize.width / 15) + 30
    }
}

extension Animation {
    func `repeat`(while expression: Bool, autoreverses: Bool = true) -> Animation {
        if expression {
            return self.repeatForever(autoreverses: autoreverses)
        } else {
            return self
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

extension URLCache {
    static let imageCache = URLCache(memoryCapacity: 512*1000*1000, diskCapacity: 10*1000*1000*1000)
}

extension DateFormatter {
    static func customFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter
    }
}


