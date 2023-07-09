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
    
    @EnvironmentObject var interfaceData: InterfaceData
    @EnvironmentObject var mainViewModel: MainViewModel

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
                
                TopBar<BackButton?, Text>(
                    text: selectedDate.barTitleDate(),
                    leftButton: procedure != nil ? BackButton() : nil,
                    action: { selectedDate = Date() }
                )
                
                BarDatePicker(
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
                        timeSlotButton(timeSlot: timeSlot)
                    }
                }
                .padding(.horizontal)
                .alert("booked-time-alert-string", isPresented: $showAlert) {
                    Button("got-it-string", role: .cancel) { }
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
                
                mainButton
                
            }
            .padding(.bottom, 20)
            .navigationBarBackButtonHidden(true)
            .onChange(of: selectedDate) { newDate in
                handleSelectedDateChange(newDate: newDate)
            }
            .onAppear {
                loadData()
            }
            .fullScreenCover(isPresented: $fullCover, content: {
                if let order {
                    DoneOrderView(order: order, withPhoto: false, selectedTab: $selectedTab)
                }
            })
        }
    }
}

struct DateTimeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        
        let interfaceData = InterfaceData()

        VStack {
            DateTimeSelectionView(mainButtonTitle: "Add appoinment", selectedTab: .constant(.plus))
                .environmentObject(interfaceData)
                .environmentObject(MainViewModel(data: interfaceData))
        }
        .padding(.horizontal, 20)
        .background(Color.backgroundColor)
    }
}

// MARK: Components

extension DateTimeSelectionView {
    func timeSlotButton(timeSlot: String) -> some View {
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
    
    var mainButton: some View {
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

}

// MARK: Functions

extension DateTimeSelectionView {
    
    func addNewOrderAction(procedure: ProcedureModel) async throws {
        guard let client else { return }
        
        let order = OrderModel(orderId: UUID().uuidString, procedureId: procedure.procedureId, doctorId: doctor?.userId ?? "", clientId: client.userId, date: createTimestamp(from: selectedDate, time: selectedTime, procedure: nil)!, end: createTimestamp(from: selectedDate, time: selectedTime, procedure: procedure)!, isDone: false, price: procedure.cost)
        
        allOrders = try await mainViewModel.orderViewModel.getDayMonthOrders(date: selectedDate, selectionMode: .day, doctorId: nil, firstDate: nil, secondDate: nil)
        personalOrdersTime = try await mainViewModel.orderViewModel.getDayOrderTimes(date: selectedDate, selectionMode: .day, doctorId: doctor?.userId)
        
        if !checkIfDisabled(time: selectedTime) {
            try await mainViewModel.orderViewModel.addNewOrder(order: order)
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
            let end = createTimestamp(from: selectedDate, time: selectedTime, procedure: interfaceData.procedures.first(where: { $0.procedureId == order.procedureId })) else {
            print("Edit order action error")
            throw URLError(.badServerResponse)
        }
                
        allOrders = try await mainViewModel.orderViewModel.getDayMonthOrders(date: selectedDate, selectionMode: .day, doctorId: nil, firstDate: nil, secondDate: nil)
        personalOrdersTime = try await mainViewModel.orderViewModel.getDayOrderTimes(date: selectedDate, selectionMode: .day, doctorId: order.doctorId)

        if !checkIfDisabled(time: selectedTime) {
            try await mainViewModel.orderViewModel.editOrderTime(orderId: order.orderId, date: date, end: end)
            
            interfaceData.activeLastDocument = nil
            interfaceData.activeOrders = []
            try await mainViewModel.orderViewModel.getRequiredOrders(dataFetchMode: .user, isDone: false, countLimit: 6)
            
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

//  Тут было 0..<28
        for _ in 0..<27 {
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
            localProcedure = interfaceData.procedures.first(where: { $0.procedureId == order.procedureId })
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

            guard let matchedProcedure = interfaceData.procedures.first(where: { $0.procedureId == localProcedure.procedureId }) else { return true }
            guard (matchedProcedure.parallelQuantity - matches.count) > 0 else {
                return true
            }
        }
        
        if !(interfaceData.user?.isDoctor ?? false) {
            guard checkCustomSchedule(orderDate: orderDate, endOfFutureOrder: endOfFutureOrder) == false else { return true }
            guard checkVacation() == false else { return true }
        }

        return false
    }
    
    func checkCustomSchedule(orderDate: Date, endOfFutureOrder: Date) -> Bool {
        guard
            let doctor = self.doctor,
            doctor.customSchedule != nil,
            let scheduleTimes = doctor.scheduleTimes,
            let startOfDay = scheduleTimes.keys.first,
            let endOfDay = scheduleTimes.values.first else {
            return false
        }

        let fullStartDate = createFullDate(from: selectedDate, time: startOfDay) ?? Date()
        let fullEndDate = createFullDate(from: selectedDate, time: endOfDay) ?? Date()

        return !(orderDate >= fullStartDate && endOfFutureOrder <= fullEndDate)
    }
    
    func checkVacation() -> Bool {
        let calendar = Calendar.current

        guard
            let doctor = self.doctor,
            doctor.vacation != nil,
            let vacationDates = doctor.vacationDates,
            let vacationEndDate = calendar.date(byAdding: .day, value: 1, to: vacationDates[1].dateValue()),
            vacationDates.count == 2 else {
            return false
        }
        
        let vacationStartDate = vacationDates[0].dateValue()

        return selectedDate >= vacationStartDate && selectedDate < vacationEndDate
    }
    
    func handleSelectedDateChange(newDate: Date) {
        Task {
            disabledAllButtons = true
            personalOrdersTime = try await mainViewModel.orderViewModel.getDayOrderTimes(date: newDate, selectionMode: .day, doctorId: doctor?.userId)
            allOrders = try await mainViewModel.orderViewModel.getDayMonthOrders(date: newDate, selectionMode: .day, doctorId: nil, firstDate: nil, secondDate: nil)
            generateTimeSlots()
            disabledAllButtons = false
        }
    }
    
    func loadData() {
        Task {
            disabledAllButtons = true
            personalOrdersTime = try await mainViewModel.orderViewModel.getDayOrderTimes(date: selectedDate, selectionMode: .day, doctorId: doctor?.userId)
            allOrders = try await mainViewModel.orderViewModel.getDayMonthOrders(date: selectedDate, selectionMode: .day, doctorId: nil, firstDate: nil, secondDate: nil)
            generateTimeSlots()
            disabledAllButtons = false
        }
    }

}
