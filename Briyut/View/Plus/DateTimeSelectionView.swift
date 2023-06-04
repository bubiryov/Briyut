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
    var order: OrderModel? = nil
    var mainButtonTitle: String
    var client: DBUser? = nil
    @State private var selectedTime = ""
    @State private var selectedDate = Date()
    @State var personalOrdersTime: [(Date, Date)] = []
    @State private var allOrders: [OrderModel] = []
    @State private var showAlert: Bool = false
    @State var timeSlots: [String] = []
    @State private var disabledAllButtons: Bool = true
    @Binding var selectedTab: Tab
    @Binding var doneAnimation: Bool
                                            
    var body: some View {

        VStack {
            
            BarTitle<BackButton?, Text>(text: DateFormatter.customFormatter(format: "d MMMM yyyy").string(from: selectedDate), leftButton: procedure != nil ? BackButton() : nil)
            
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
                    .buttonStyle(.plain)
                    .disabled(disabledAllButtons ? true : checkIfDisabled(time: timeSlot))
                    .opacity(disabledAllButtons ? 0.5 : checkIfDisabled(time: timeSlot) ? 0.5 : 1)
                    .cornerRadius(ScreenSize.width / 30)
                }
            }
            .padding(.horizontal)
            .alert("Sorry, this time has just been taken", isPresented: $showAlert) {
                Button("Got it", role: .cancel) { }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        if gesture.translation.width > 100 && procedure != nil {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
            )
            
            Spacer()
            
            Button {
                if let procedure {
                    Task {
                        try await addNewOrderAction(procedure: procedure)
                    }
                } else if let order {
                    Task {
                        try await editOrderAction(order: order)
                    }
                }
            } label: {
                AccentButton(text: mainButtonTitle, isButtonActive: selectedTime != "" ? true : false)
            }
            .disabled(selectedTime != "" ? false : true)
            
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: selectedDate) { newDate in
            Task {
                disabledAllButtons = true
                personalOrdersTime = try await vm.getDayOrderTimes(date: newDate, doctorId: doctor?.userId)
                allOrders = try await vm.getDayOrders(date: newDate, doctorId: nil)
                generateTimeSlots()
                disabledAllButtons = false
            }
        }
        .onAppear {
            Task {
                disabledAllButtons = true
                personalOrdersTime = try await vm.getDayOrderTimes(date: selectedDate, doctorId: doctor?.userId)
                allOrders = try await vm.getDayOrders(date: selectedDate, doctorId: nil)
                generateTimeSlots()
                disabledAllButtons = false
            }
        }
    }
    
    func addNewOrderAction(procedure: ProcedureModel) async throws {
        guard let client else { return }
        
        let order = OrderModel(orderId: UUID().uuidString, procedureId: procedure.procedureId, doctorId: doctor?.userId ?? "", clientId: client.userId, date: createTimestamp(from: selectedDate, time: selectedTime, procedure: nil)!, end: createTimestamp(from: selectedDate, time: selectedTime, procedure: procedure)!, isDone: false, price: procedure.cost)
        
        allOrders = try await vm.getDayOrders(date: selectedDate, doctorId: nil)
        personalOrdersTime = try await vm.getDayOrderTimes(date: selectedDate, doctorId: doctor?.userId)

        if !checkIfDisabled(time: selectedTime) {
            try await vm.addNewOrder(order: order)

            withAnimation {
                doneAnimation = true
            }

            try await Task.sleep(nanoseconds: 3_000_000_000)

            withAnimation {
                doneAnimation = false
                selectedTab = .home
            }
        } else {
            showAlert = true
            selectedTime = ""
            generateTimeSlots()
        }
    }
    
    func editOrderAction(order: OrderModel) async throws {
        guard
            let date = createTimestamp(from: selectedDate, time: selectedTime, procedure: nil),
            let end = createTimestamp(from: selectedDate, time: selectedTime, procedure: vm.procedures.first(where: { $0.procedureId == order.procedureId })) else {
            print("Edit order action error")
            throw URLError(.badServerResponse)
        }
                
        allOrders = try await vm.getDayOrders(date: selectedDate, doctorId: nil)
        personalOrdersTime = try await vm.getDayOrderTimes(date: selectedDate, doctorId: order.doctorId)

        if !checkIfDisabled(time: selectedTime) {
            try await vm.editOrderTime(orderId: order.orderId, date: date, end: end)
            
            if vm.user?.isDoctor ?? false {
                vm.activeLastDocument = nil
                vm.activeOrders = []
                try await vm.getAllOrders(isDone: false, countLimit: 6)
            }


            presentationMode.wrappedValue.dismiss()

            withAnimation {
                doneAnimation = true
            }

            try await Task.sleep(nanoseconds: 3_000_000_000)

            withAnimation {
                doneAnimation = false
            }
        } else {
            showAlert = true
            selectedTime = ""
            generateTimeSlots()
        }
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
                        
            if personalOrdersTime.isEmpty {
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
            
            if let time = personalOrdersTime.first(where: { $0.1 > currentTime && $0.1 < nextTime }) {
                let timeString = formatter.string(from: time.1)
                slots.append(timeString)
                currentTime = time.1
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

    private func createTimestamp(from date: Date, time: String, procedure: ProcedureModel?) -> Timestamp? {
        
        if let procedure {
            guard let date = createFullDate(from: date, time: time)?.addingTimeInterval(TimeInterval(procedure.duration * 60)) else {
                return nil
            }
            return Timestamp(date: date)
        } else {
            guard let date = createFullDate(from: date, time: time) else {
                return nil
            }
            return Timestamp(date: date)
        }
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
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .timeZone], from: createFullDate(from: selectedDate, time: time) ?? Date())

        guard let orderDate = calendar.date(from: dateComponents) else {
            return true
        }
        
        guard orderDate > Date() else { return true }
        
        var localProcedure: ProcedureModel? = nil
        var duration: TimeInterval = 0
        var localPersonalOrdersTime = personalOrdersTime
        var localAllOrders = allOrders
        
        if let procedure {
            localProcedure = procedure
        } else if let order {
            localAllOrders = allOrders.filter({ $0.date.dateValue() != order.date.dateValue() })
            localPersonalOrdersTime = personalOrdersTime.filter({ $0.0 != order.date.dateValue() })
            localProcedure = vm.procedures.first(where: { $0.procedureId == order.procedureId })
        }

        guard let localProcedure else { return true }
            
        duration = TimeInterval(localProcedure.duration * 60)
        
        let endOfFutureOrder = orderDate.addingTimeInterval(duration)
        
        if localPersonalOrdersTime.contains(where: { orderDate >= $0.0 && orderDate < $0.1 }) {
            return true
        }

        if let nextOrder = localPersonalOrdersTime.first(where: { $0.0 > orderDate }) {
            guard nextOrder.0 >= endOfFutureOrder else { return true }
        }

        let matches = localAllOrders.filter {
            $0.procedureId == localProcedure.procedureId && orderDate >= $0.date.dateValue() && orderDate < $0.end.dateValue() ||
            $0.procedureId == localProcedure.procedureId && endOfFutureOrder > $0.date.dateValue() && endOfFutureOrder <= $0.end.dateValue() }

        if matches.count > 0 {

            guard let matchedProcedure = vm.procedures.first(where: { $0.procedureId == localProcedure.procedureId }) else { return true }
            guard (matchedProcedure.parallelQuantity - matches.count) > 0 else {
                return true
            }
        }

        return false
    }
}

struct DateTimeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        DateTimeSelectionView(mainButtonTitle: "Add appoinment", selectedTab: .constant(.plus), doneAnimation: .constant(false))
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
                                
                ForEach(-2...2, id: \.self) { day in
                    let date = Calendar.current.date(byAdding: .day, value: day, to: selectedDate) ?? selectedDate
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
                    .scaleEffect(day == -2 || day == 2 ? 0.7 : (day == -1 || day == 1 ? 0.8 : 1))
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
//            .padding(.horizontal)
        }
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.width > 100 && selectedDate >= Date() {
                        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                    } else if gesture.translation.width < 100 {
                        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                    }
                }
        )

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
