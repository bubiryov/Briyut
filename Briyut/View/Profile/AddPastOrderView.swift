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
                
                BarTitle<Text, Text>(text: "Add past appointment")
                
                HStack {
                    Text("Users")
                        .font(Mariupol.medium, 17)
                    
                    Spacer()
                    
                    Picker("", selection: $selectedUser) {
                        ForEach(vm.users.sorted(), id: \.userId) { user in
                            Text("\(user.name ?? "Anonymous") \(user.name != nil ? user.lastName ?? "" : "")")
                                .tag(user as DBUser?)
                        }
                    }
                    .tint(.staticMainColor)
                }
                
                HStack {
                    Text("Procedures")
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
                
                CustomDatePicker(selectedDate: $selectedDate, selectedTime: $selectedTime)
                
//                DatePicker(selection: $selectedDate, in: ...Date()) {
//                    Text("Date")
//                        .font(Mariupol.medium, 17)
//                }
//                .tint(.staticMainColor)
                
                Button {
                    if let selectedUser, let selectedProcedure, let user = vm.user {
                        let newOrder = OrderModel(
                            orderId: UUID().uuidString,
                            procedureId: selectedProcedure.procedureId,
                            doctorId: user.userId,
                            clientId: selectedUser.userId,
                            date: Timestamp(date: selectedDate.addingTimeInterval(TimeInterval(selectedProcedure.duration * 60))),
                            end: Timestamp(date: selectedDate),
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
                        text: "Add",
                        isButtonActive: selectedUser != nil && selectedProcedure != nil,
                        animation: loading)
                }
                .disabled(selectedUser == nil || selectedProcedure == nil)
                
                Spacer()
            }
            .padding(.top)
            .padding(.horizontal, 20)
        }
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
                Text("Date")
                    .font(Mariupol.medium, 17)
            }
            .tint(.mainColor)
            .datePickerStyle(.compact)
            
            DatePicker("Time", selection: $selectedTime, in: ...Date(), displayedComponents: [.hourAndMinute])
                .datePickerStyle(.compact)
                .tint(.mainColor)
                .labelsHidden()
                .onChange(of: selectedTime, perform: { date in
                    selectedTime = roundDateToNearestInterval(date: date, interval: timeStep)
                })
                .environment(\.locale, Locale(identifier: "en_GB"))
        }
        .onAppear {
            selectedTime = roundDateToNearestInterval(date: selectedTime, interval: timeStep)
        }
    }
    
    private func roundDateToNearestInterval(date: Date, interval: TimeInterval) -> Date {
        let timeInterval = date.timeIntervalSinceReferenceDate
        let roundedInterval = (timeInterval / interval).rounded() * interval

        let roundedDate = Date(timeIntervalSinceReferenceDate: roundedInterval)

        if roundedDate > Date() {
            return roundedDate.addingTimeInterval(-interval)
        }

        return roundedDate
    }


//    private func roundDateToNearestInterval(date: Date, interval: TimeInterval) -> Date {
//        let timeInterval = date.timeIntervalSinceReferenceDate
//        let roundedInterval = (timeInterval / interval).rounded() * interval
//        return Date(timeIntervalSinceReferenceDate: roundedInterval)
//    }
}
