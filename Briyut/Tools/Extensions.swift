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
    static let destructiveColor = Color("DestructiveColor")
    static let backgroundColor = Color("BackgroundColor")
    static let staticMainColor = Color(red: 0.455, green: 0.749, blue: 0.765)
}

extension View {
    func font(_ mariupol: Mariupol, _ size: CGFloat) -> some View {
        return self.font(.custom(mariupol.rawValue, size: size))
    }
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
        
        let language = Locale.preferredLanguages.first ?? "uk"
        if !language.hasPrefix("en") {
            formatter.locale = Locale(identifier: "uk_UA")
        } else {
            formatter.locale = Locale(identifier: "en_US")
        }
        
        return formatter
    }
    
    func getMonthNameInNominativeCase(from date: Date) -> String {
        let monthString = self.string(from: date)
        
        let monthMapping: [String: String] = [
            "January": "Січень",
            "February": "Лютий",
            "March": "Березень",
            "April": "Квітень",
            "May": "Травень",
            "June": "Червень",
            "July": "Липень",
            "August": "Серпень",
            "September": "Вересень",
            "October": "Жовтень",
            "November": "Листопад",
            "December": "Грудень"
        ]

        return monthMapping[monthString] ?? monthString
    }
}

extension Date {
    func barTitleDate() -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        if calendar.isDate(self, inSameDayAs: today) {
            return "today-string"
        } else if calendar.isDate(self, inSameDayAs: tomorrow) {
            return "tommorow-string"
        } else if calendar.isDate(self, inSameDayAs: yesterday) {
            return "yesterday-string"
        } else {
            let formatter = DateFormatter.customFormatter(format: "d MMMM yyyy")
            return formatter.string(from: self)
        }
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

