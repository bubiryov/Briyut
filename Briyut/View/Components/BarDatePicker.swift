//
//  BarDatePicker.swift
//  Briyut
//
//  Created by Egor Bubiryov on 03.07.2023.
//

import SwiftUI

struct BarDatePicker: View {
    
    @Binding var selectedDate: Date
    let mode: DatePickerMode
    let pastTime: Bool
    
    var body: some View {
        VStack {
            HStack {
                if mode == .days {
                    leftButton
                }
                
                ForEach(-2...2, id: \.self) { day in
                    dateButton(day: day)
                }
                
                if mode == .days {
                    rightButton
                }
            }
        }
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.width > 100 && (selectedDate >= Date() || pastTime) {
                        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                    } else if gesture.translation.width < 100 {
                        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                    }
                }
        )
        .onChange(of: selectedDate) { _ in
            Haptics.shared.play(.light)
        }
    }
}

struct BarDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        BarDatePicker(
            selectedDate: .constant(Date()),
            mode: .days,
            pastTime: true
        )
    }
}

// MARK: Components

extension BarDatePicker {
    var leftButton: some View {
        Button(action: {
            let value = leftButtonStep(pastTime: pastTime)
            selectedDate = Calendar.current.date(byAdding: .day, value: -value, to: selectedDate) ?? selectedDate
        }) {
            Circle()
                .frame(width: 40, height: 40)
                .foregroundColor(Color.mainColor)
                .overlay(
                    Image("back")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundColor(.white)
                )
        }
        .disabled(pastTime ? false : shouldEnableLeftButton(selectedDate: selectedDate))
        .opacity(pastTime ? 1 : shouldEnableLeftButton(selectedDate: selectedDate) ? 0.5 : 1)
    }
    
    var rightButton: some View {
        Button(action: {
            selectedDate = Calendar.current.date(byAdding: .day, value: 5, to: selectedDate) ?? selectedDate
        }) {
            Circle()
                .frame(width: 40, height: 40)
                .foregroundColor(Color.mainColor)
                .overlay(
                    Image("next")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundColor(.white)
                )
        }

    }
    
    func dateButton(day: Int) -> some View {
        let date = Calendar.current.date(byAdding: mode == .days ? .day : .month, value: day, to: selectedDate) ?? selectedDate
        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)

        return Button(action: {
            selectedDate = date
        }) {
            VStack(spacing: 2) {
                if mode == .days {
                    Text(DateFormatter.customFormatter(format: "d").string(from: date))
                        .font(Mariupol.medium, 17)
                        .foregroundColor(isSelected ? .white : .primary)
                }
                Text(DateFormatter.customFormatter(format: mode == .days ? "E" : "MMM").string(from: date))
                    .foregroundColor(isSelected ? .white : .primary)
                    .font(Mariupol.regular, 11)
            }
            .frame(width: ScreenSize.height * 0.05, height: ScreenSize.width * 0.15)
            .background(isSelected ? Color.mainColor : Color.clear)
            .cornerRadius(ScreenSize.width / 30)
        }
        .disabled(pastTime ? false : checkIfDisabled(date: date))
        .opacity(pastTime ? 1 : checkIfDisabled(date: date) ? 0.3 : 1)
    }
}

// MARK: Functions

extension BarDatePicker {
    func checkIfDisabled(date: Date) -> Bool {
        let currentDate = Calendar.current.startOfDay(for: Date())
        let selectedDate = Calendar.current.startOfDay(for: date)
        return selectedDate < currentDate
    }
    
    func shouldEnableLeftButton(selectedDate: Date) -> Bool {
        let currentDate = Calendar.current.startOfDay(for: Date())
        
        let startDate = Calendar.current.date(byAdding: .day, value: -2, to: currentDate) ?? currentDate
        
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        
        return selectedDate >= startDate && selectedDate <= endDate
    }
    
    func leftButtonStep(pastTime: Bool) -> Int {
        let currentDate = Calendar.current.startOfDay(for: Date())
        let difference = Calendar.current.dateComponents([.day], from: currentDate, to: selectedDate).day ?? 0
        
        var value: Int {
            if pastTime {
                return 5
            } else {
                if difference >= 5 {
                    return 5
                } else {
                    return difference
                }
            }
        }
        return value
    }

}
