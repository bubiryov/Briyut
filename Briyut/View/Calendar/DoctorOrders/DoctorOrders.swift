//
//  DoctorOrders.swift
//  Briyut
//
//  Created by Egor Bubiryov on 15.05.2023.
//

import SwiftUI

struct DoctorOrders: View {
    
    @EnvironmentObject var interfaceData: InterfaceData
    @EnvironmentObject var mainViewModel: MainViewModel
    @State private var selectedDate: Date = Date()
    @State private var selectedDoctor: DBUser? = nil
    @State private var dayOrders: [(OrderModel, Bool)] = []
    @State private var isEditing: Bool = false
    @State private var showAlert: Bool = false
    @State private var noOrders: Bool? = nil
        
    var body: some View {
        VStack {
            TopBar<EditButton, DoctorMenuPicker>(
                text: selectedDate.barTitleDate(),
                leftButton: selectedDoctor == interfaceData.user ? EditButton(isEditing: $isEditing) : nil,
                rightButton: DoctorMenuPicker(
                    interfaceData: interfaceData,
                    doctors: interfaceData.doctors.map(DoctorOption.user),
                    selectedDoctor: $selectedDoctor),
                action: { selectedDate = Date() }
            )
                        
            BarDatePicker(
                selectedDate: $selectedDate,
                mode: .days,
                pastTime: true
            )
            
            if !(noOrders ?? false) {
                ScrollView {
                    LazyVStack {
                        ForEach($dayOrders, id: \.0.orderId) { order in
                            DoctorOrderRow(interfaceData: interfaceData, mainViewModel: mainViewModel, dayOrders: $dayOrders, order: order, isEditing: $isEditing, selectedDoctor: selectedDoctor, selectedDate: selectedDate)
                                .onAppear {
                                    if let currentIndex = dayOrders.firstIndex(where: { $0.0.date.dateValue() <= Date() && $0.0.end.dateValue() > Date()}) {
                                        dayOrders[currentIndex] = (dayOrders[currentIndex].0, true)
                                    }
                                }
                        }
                    }
                    .padding(.top, 5)
                }
                .scrollIndicators(.hidden)
            } else {
                Spacer()
                Text(selectedDate < Date() ? "no-appointments-on-this-day-string" : "no-any-appointments-string")
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .background(Color.backgroundColor)
        .onAppear {
            selectedDoctor = interfaceData.user
        }
        .onChange(of: selectedDate) { _ in
            onChangeUpdate()
        }
        .onChange(of: selectedDoctor) { _ in
            onChangeUpdate()
        }
        .onChange(of: isEditing) { newValue in
            updateIsEditing(newValue)
        }
    }
}

struct DoctorOrders_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            DoctorOrders()
                .environmentObject(InterfaceData())
        }
        .padding(.horizontal, 20)
        .background(Color.backgroundColor)
    }
}

extension DoctorOrders {
    
    private func onChangeUpdate() {
        Task {
            do {
                let orders = try await mainViewModel.orderViewModel.getDayMonthOrders(date: selectedDate, selectionMode: .day, doctorId: selectedDoctor?.userId, firstDate: nil, secondDate: nil)
                dayOrders = orders.map {($0, false)}
                isEditing = false
                if orders.isEmpty {
                    noOrders = true
                } else {
                    noOrders = false
                }
            } catch {
                print("Ошибка при обновлении выбранной даты: \(error)")
            }
        }
    }
    
    private func updateIsEditing(_ newValue: Bool) {
        withAnimation(.easeInOut(duration: 0.15)) {
            dayOrders = dayOrders.map {
                if $0.0.date.dateValue() < Date() && $0.0.end.dateValue() > Date() {
                    return ($0.0, true)
                } else {
                    return ($0.0, newValue)
                }
            }
        }
    }
}
