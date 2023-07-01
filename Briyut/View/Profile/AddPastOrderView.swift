//
//  AddPastOrderView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 29.06.2023.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct AddPastOrderView: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedUser: DBUser? = nil
    @State private var selectedProcedure: ProcedureModel? = nil
    @State private var selectedDate: Date = Date()
    @State private var selectedTime: Date = Date()
    @State private var loading: Bool = false
        
    var body: some View {

        ZStack {
            
            Color.backgroundColor.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                
                BarTitle<Text, Text>(text: "add-past-appointment-string")
                                
                HStack {
                    Text("user-string")
                        .font(Mariupol.medium, 17)
                    
                    Spacer()
                    
                    Picker("", selection: $selectedUser) {
                        ForEach(vm.users.sorted(), id: \.userId) { user in
                            Text("\(user.name ?? "anonymous-string") \(user.name != nil ? user.lastName ?? "" : "")")
                                .tag(user as DBUser?)
                        }
                    }
                    .tint(.staticMainColor)
                }
                
                HStack {
                    Text("procedure-string")
                        .font(Mariupol.medium, 17)
                    
                    Spacer()
                    
                    Picker("", selection: $selectedProcedure) {
                        ForEach(vm.procedures, id: \.procedureId) { procedure in
                            Text(procedure.name)
                                .tag(procedure as ProcedureModel?)
                        }
                    }
                    .tint(.staticMainColor)
                }
                
                CustomDatePicker(
                    selectedDate: $selectedDate,
                    selectedTime: $selectedTime
                )
                                
                Button {
                    Haptics.shared.play(.light)
                    if let selectedUser, let selectedProcedure, let user = vm.user {
                        let newOrder = OrderModel(
                            orderId: UUID().uuidString,
                            procedureId: selectedProcedure.procedureId,
                            doctorId: user.userId,
                            clientId: selectedUser.userId,
                            date: Timestamp(date: getCombinedDate()),
                            end: Timestamp(date: getCombinedDate().addingTimeInterval(TimeInterval(selectedProcedure.duration * 60))),
                            isDone: true,
                            price: selectedProcedure.cost
                        )
                        Task {
                            do {
                                loading = true
                                try await vm.addNewOrder(order: newOrder)
                                vm.allLastDocument = nil
                                vm.allOrders = []
                                try await vm.getAllOrders(dataFetchMode: .all, count: 10, isDone: nil)
                                loading = false
                                presentationMode.wrappedValue.dismiss()
                            } catch {
                                print("Can't add past orders")
                            }
                        }
                    }
                } label: {
                    AccentButton(
                        text: "add-string",
                        isButtonActive: selectedUser != nil && selectedProcedure != nil && getCombinedDate() < Date(),
                        animation: loading)
                }
                .disabled(selectedUser == nil || selectedProcedure == nil || getCombinedDate() >= Date())
                
                Spacer()
            }
            .padding(.top)
            .padding(.horizontal, 20)
        }
    }
    
    private func getCombinedDate() -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.day, .month, .year], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
        let combinedDateTime = calendar.date(bySettingHour: timeComponents.hour ?? 0,
                                             minute: timeComponents.minute ?? 0,
                                             second: 0,
                                             of: calendar.date(from: dateComponents) ?? Date()) ?? Date()
        return combinedDateTime
    }

}

struct AddPastOrderView_Previews: PreviewProvider {
    static var previews: some View {
        AddPastOrderView()
            .environmentObject(ProfileViewModel())
    }
}


struct CustomDatePicker: View {
    
    @Binding var selectedDate: Date
    @Binding var selectedTime: Date
    var timeStep: TimeInterval = 15 * 60

    var body: some View {
        HStack {
        
            
            DatePicker(selection: $selectedDate, in: ...Date(), displayedComponents: [.date]) {
                Text("date-string")
                    .font(Mariupol.medium, 17)
            }
            .tint(.mainColor)
            .datePickerStyle(.compact)
            
            DatePicker("time-string", selection: $selectedTime, displayedComponents: [.hourAndMinute])
                .datePickerStyle(.compact)
                .tint(.mainColor)
                .labelsHidden()
                .onChange(of: selectedTime, perform: { date in
                    selectedTime = roundDateToNearestInterval(date: date, interval: timeStep)
                })
                .environment(\.locale, Locale(identifier: "uk"))
        }
        .onAppear {
            selectedTime = roundDateToNearestInterval(date: selectedTime, interval: timeStep)
        }
    }
    
//    private func roundDateToNearestInterval(date: Date, interval: TimeInterval) -> Date {
//        let timeInterval = date.timeIntervalSinceReferenceDate
//        let roundedInterval = (timeInterval / interval).rounded() * interval
//
//        let roundedDate = Date(timeIntervalSinceReferenceDate: roundedInterval)
//
//        if roundedDate > Date() {
//            return roundedDate.addingTimeInterval(-interval)
//        }
//
//        return roundedDate
//    }


    private func roundDateToNearestInterval(date: Date, interval: TimeInterval) -> Date {
        let timeInterval = date.timeIntervalSinceReferenceDate
        let roundedInterval = (timeInterval / interval).rounded() * interval
        return Date(timeIntervalSinceReferenceDate: roundedInterval)
    }
}
