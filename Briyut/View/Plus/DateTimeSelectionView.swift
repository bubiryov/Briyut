//
//  DateTimeSelectionView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 18.05.2023.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DateTimeSelectionView: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    var doctor: DBUser? = nil
    var procedure: ProcedureModel? = nil
    @Binding var selectedTab: Tab
    @State private var selectedTime = ""
    @State private var selectedDate = Date()
    @State var ordersTime = [Date: Date]()
    @State private var disableAllButtons: Bool = true
    @Binding var doneAnimation: Bool
        
    let dayMonthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
    
    @State var timeSlots: [String] = []
                
    var body: some View {
//        VStack {
            VStack {
                
                BarTitle<BackButton, Text>(text: dayMonthFormatter.string(from: selectedDate), leftButton: BackButton())
                
                CustomDatePicker(selectedDate: $selectedDate, selectedTime: $selectedTime)
                
                Spacer()
                
                LazyVGrid(columns: Array(repeating: GridItem(), count: 4), spacing: 20) {
                    ForEach(timeSlots, id: \.self) { timeSlot in
                        Button(action: {
                            withAnimation(nil) {
                                selectedTime = timeSlot
                            }
                        }) {
                            Text(timeSlot)
                                .foregroundColor(selectedTime == timeSlot ? .white : .black)
                                .bold()
                                .frame(width: ScreenSize.width * 0.2, height: ScreenSize.height * 0.05)
                                .background(
                                    RoundedRectangle(cornerRadius: ScreenSize.width / 30)
                                        .strokeBorder(Color.mainColor, lineWidth: 2)
                                        .background(
                                            selectedTime == timeSlot ? Color.mainColor : Color.clear
                                        )
                                )
                        }
                        .cornerRadius(ScreenSize.width / 30)
                        .buttonStyle(.plain)
                        .disabled(checkIfDisabled(time: timeSlot))
                        .disabled(disableAllButtons)
                        .opacity(checkIfDisabled(time: timeSlot) || disableAllButtons ? 0.5 : 1)
                    }
                }
                .padding(.horizontal)

                Spacer()
                
                Button {
                    let order = OrderModel(orderId: UUID().uuidString, procedureId: procedure?.procedureId ?? "", procedureName: procedure?.name ?? "", doctorId: doctor?.userId ?? "", doctorName: "\(doctor?.name ?? "") \(doctor?.lastName ?? "")", clientId: vm.user?.userId ?? "", date: createTimestamp(from: selectedDate, time: selectedTime)!, isDone: false, price: procedure?.cost ?? 0)
                    Task {
                        
                        try await vm.addNewOrder(order: order)
                        
                        withAnimation {
                            doneAnimation = true
                        }
                        
                        try await Task.sleep(nanoseconds: 3_000_000_000)
                        
                        withAnimation {
                            doneAnimation = false
                            selectedTab = .home
                        }
                    }
                } label: {
                    AccentButton(text: "Add order", isButtonActive: selectedTime != "" ? true : false)
                }
                .disabled(selectedTime != "" ? false : true)
                
            }
            .navigationBarBackButtonHidden(true)
            .onChange(of: selectedDate) { _ in
                Task {
                    disableAllButtons = true
                    timeSlots = []
                    ordersTime = try await vm.getDayOrders(date: selectedDate)
                    generateTimeSlots()
                    disableAllButtons = false
                }
            }
            .onAppear {
                Task {
                    disableAllButtons = true
                    timeSlots = []
                    ordersTime = try await vm.getDayOrders(date: Date())
                    generateTimeSlots()
                    disableAllButtons = false
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                    if gesture.translation.width > 100 {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
//        }
//        .padding(.horizontal, 20)
    }
    
    func generateTimeSlots() {
        var slots = [String]()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let calendar = Calendar.current
        
        var currentTime = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: selectedDate)!
        let endTime = calendar.date(bySettingHour: 21, minute: 0, second: 0, of: selectedDate)!
        
        let interval = 30 * 60
                
        for _ in 0..<28 {
            let nextTime = calendar.date(byAdding: .second, value: interval, to: currentTime)!
                        
            if ordersTime.isEmpty {
                guard currentTime <= endTime else { break }
                let timeString = formatter.string(from: currentTime)
                slots.append(timeString)
                currentTime = nextTime
                continue
            }
            
            if slots.isEmpty {
                let timeString = formatter.string(from: currentTime)
                slots.append(timeString)
                currentTime = nextTime
            }
            
            if let time = ordersTime.first(where: { $0.value > currentTime && $0.value < nextTime }) {
                let timeString = formatter.string(from: time.value)
                slots.append(timeString)
                currentTime = time.value
            } else {
                if nextTime <= endTime {
                    let timeString = formatter.string(from: nextTime)
                    slots.append(timeString)
                    currentTime = nextTime
                }
            }
        }
                
        timeSlots = slots
    }

    private func createTimestamp(from date: Date, time: String) -> Timestamp? {
        guard let date = createFullDate(from: date, time: time) else {
            return nil
        }
        return Timestamp(date: date)
    }
        
    private func createFullDate(from date: Date, time: String) -> Date? {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        guard let timeDate = timeFormatter.date(from: time) else {
            return nil
        }
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: timeDate)
        
        let mergedComponents = DateComponents(calendar: calendar, year: dateComponents.year, month: dateComponents.month, day: dateComponents.day, hour: timeComponents.hour, minute: timeComponents.minute)
        
        guard let mergedDate = calendar.date(from: mergedComponents) else {
            return nil
        }
        return mergedDate
    }
    
    private func checkIfDisabled(time: String) -> Bool {
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .timeZone], from: createFullDate(from: selectedDate, time: time)!)
        
        guard let orderDate = calendar.date(from: dateComponents) else {
            return true
        }
        
        let duration = TimeInterval(((procedure?.duration) ?? 0) * 60)
        
        let endOfFutureOrder = orderDate.addingTimeInterval(duration)
        
        guard orderDate > Date() else { return true }
        
        for (start, end) in ordersTime {
            if orderDate >= start && orderDate < end {
                return true
            }
            
            if let nextStart = ordersTime.first(where: { $0.key > orderDate }) {
                guard nextStart.key >= endOfFutureOrder else {
                    return true
                }
            }
        }
        return false
    }
}

struct DateTimeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        DateTimeSelectionView(selectedTab: .constant(.plus), doneAnimation: .constant(false))
            .environmentObject(ProfileViewModel())
    }
}

struct CustomDatePicker: View {
    @Binding var selectedDate: Date
    @Binding var selectedTime: String

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    let value = leftButtonStep()
                    selectedDate = Calendar.current.date(byAdding: .day, value: -value, to: selectedDate) ?? selectedDate
                    selectedTime = ""
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
                .disabled(shouldEnableLeftButton(selectedDate: selectedDate))
                .opacity(shouldEnableLeftButton(selectedDate: selectedDate) ? 0.5 : 1)
                                
                ForEach(-2...2, id: \.self) { offset in
                    let date = Calendar.current.date(byAdding: .day, value: offset, to: selectedDate) ?? selectedDate
                    let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                    
                    Button(action: {
                        selectedDate = date
                        selectedTime = ""
                    }) {
                        VStack(spacing: 2) {
                            Text(dateFormatter.string(from: date))
                                .foregroundColor(isSelected ? .white : .primary)
                                .bold()
                                .font(.system(size: 16))
                            Text(weekdayFormatter.string(from: date))
                                .foregroundColor(isSelected ? .white : .primary)
                                .font(.system(size: 12))
                        }
                        .frame(width: ScreenSize.height * 0.05, height: ScreenSize.width * 0.15)

                        .background(isSelected ? Color.mainColor : Color.clear)
                        .cornerRadius(ScreenSize.width / 30)
                    }
                    .disabled(checkIfDisabled(date: date))
                    .opacity(checkIfDisabled(date: date) ? 0.3 : 1)
                }
                                
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .day, value: 5, to: selectedDate) ?? selectedDate
                    selectedTime = ""
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
            .padding(.horizontal)
        }
    }
    
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
    
    func leftButtonStep() -> Int {
        let currentDate = Calendar.current.startOfDay(for: Date())
        let difference = Calendar.current.dateComponents([.day], from: currentDate, to: selectedDate).day ?? 0
        
        var value: Int {
            if difference >= 5 {
                return 5
            } else {
                return difference
            }
        }
        return value
    }
}
