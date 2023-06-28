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
    @State var order: OrderModel? = nil
    var mainButtonTitle: String
    var client: DBUser? = nil
    @State private var selectedTime = ""
    @State private var selectedDate = Date()
    @State var personalOrdersTime: [(Date, Date)] = []
    @State private var allOrders: [OrderModel] = []
    @State private var showAlert: Bool = false
    @State var timeSlots: [String] = []
    @State private var disabledAllButtons: Bool = true
    @State private var fullCover: Bool = false
    @State private var loading: Bool = false
    @Binding var selectedTab: Tab
                                            
    var body: some View {

        ZStack {
            
            Color.backgroundColor.edgesIgnoringSafeArea(.all)
            
            VStack {
                
                BarTitle<BackButton?, Text>(
                    text: selectedDate.barTitleDate(),
                    leftButton: procedure != nil ? BackButton() : nil,
                    action: { selectedDate = Date() }
                )
                
                CustomDatePicker(
                    selectedDate: $selectedDate,
                    mode: .days,
                    pastTime: false
                )
                .onChange(of: selectedDate) { _ in
                    selectedTime = ""
                }
                                        
                Spacer()
                
                LazyVGrid(columns: Array(repeating: GridItem(), count: 4), spacing: 20) {
                    ForEach(timeSlots, id: \.self) { timeSlot in
                        Button(action: {
                            withAnimation(nil) {
                                selectedTime = timeSlot
                            }
                        }) {
                            Text(timeSlot)
                                .foregroundColor(selectedTime == timeSlot ? .white : .primary)
                                .font(Mariupol.medium, 17)
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
                    Haptics.shared.play(.light)
                    if let procedure {
                        Task {
                            do {
                                loading = true
                                try await addNewOrderAction(procedure: procedure)
                                loading = false
                            } catch {
                                print("Can't add an order")
                                loading = false
                            }
                        }
                    } else if let order {
                        Task {
                            do {
                                loading = true
                                try await editOrderAction(order: order)
                                loading = false
                            } catch {
                                print("Can't edit the order")
                                loading = false
                            }
                        }
                    }
                } label: {
                    AccentButton(
                        text: mainButtonTitle,
                        isButtonActive: selectedTime != "" ? true : false,
                        animation: loading
                    )
                }
                .disabled((selectedTime != "" ? false : true) || loading)
            }
            .padding(.bottom, 20)
            .navigationBarBackButtonHidden(true)
            .onChange(of: selectedDate) { newDate in
                Task {
                    disabledAllButtons = true
                    personalOrdersTime = try await vm.getDayOrderTimes(date: newDate, selectionMode: .day, doctorId: doctor?.userId)
                    allOrders = try await vm.getDayMonthOrders(date: newDate, selectionMode: .day, doctorId: nil)
                    generateTimeSlots()
                    disabledAllButtons = false
                }
            }
            .onAppear {
                Task {
                    disabledAllButtons = true
                    personalOrdersTime = try await vm.getDayOrderTimes(date: selectedDate, selectionMode: .day, doctorId: doctor?.userId)
                    allOrders = try await vm.getDayMonthOrders(date: selectedDate, selectionMode: .day, doctorId: nil)
                    generateTimeSlots()
                    disabledAllButtons = false
                }
            }
            .fullScreenCover(isPresented: $fullCover, content: {
                if let order {
                    DoneOrderView(order: order, withPhoto: false, selectedTab: $selectedTab)
                }
        })
        }
    }
    
    func addNewOrderAction(procedure: ProcedureModel) async throws {
        guard let client else { return }
        
        let order = OrderModel(orderId: UUID().uuidString, procedureId: procedure.procedureId, doctorId: doctor?.userId ?? "", clientId: client.userId, date: createTimestamp(from: selectedDate, time: selectedTime, procedure: nil)!, end: createTimestamp(from: selectedDate, time: selectedTime, procedure: procedure)!, isDone: false, price: procedure.cost)
        
        allOrders = try await vm.getDayMonthOrders(date: selectedDate, selectionMode: .day, doctorId: nil)
        personalOrdersTime = try await vm.getDayOrderTimes(date: selectedDate, selectionMode: .day, doctorId: doctor?.userId)
        
        if !checkIfDisabled(time: selectedTime) {
            try await vm.addNewOrder(order: order)
            self.order = order
            fullCover = true
            try await Task.sleep(nanoseconds: 1_600_000_000)
            Haptics.shared.notify(.success)
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
                
        allOrders = try await vm.getDayMonthOrders(date: selectedDate, selectionMode: .day, doctorId: nil)
        personalOrdersTime = try await vm.getDayOrderTimes(date: selectedDate, selectionMode: .day, doctorId: order.doctorId)

        if !checkIfDisabled(time: selectedTime) {
            try await vm.editOrderTime(orderId: order.orderId, date: date, end: end)
            
//            if vm.user?.isDoctor ?? false {
                vm.activeLastDocument = nil
                vm.activeOrders = []
            try await vm.getRequiredOrders(dataFetchMode: .user, isDone: false, countLimit: 6)
//            }

            presentationMode.wrappedValue.dismiss()

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
        VStack {
            DateTimeSelectionView(mainButtonTitle: "Add appoinment", selectedTab: .constant(.plus))
                .environmentObject(ProfileViewModel())
        }
        .padding(.horizontal, 20)
//        .background(Color.backgroundColor)
    }
}

struct CustomDatePicker: View {
    @Binding var selectedDate: Date
    let mode: DatePickerMode
    let pastTime: Bool
    
    var body: some View {
        VStack {
            HStack {
                if mode == .days {
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
                
                ForEach(-2...2, id: \.self) { day in
                    let date = Calendar.current.date(byAdding: mode == .days ? .day : .month, value: day, to: selectedDate) ?? selectedDate
                    let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                    
                    Button(action: {
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
//                    .scaleEffect(day == -2 || day == 2 ? 0.7 : (day == -1 || day == 1 ? 0.8 : 1))
                }
                if mode == .days {
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
