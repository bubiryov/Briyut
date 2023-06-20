//
//  DoctorOrders.swift
//  Briyut
//
//  Created by Egor Bubiryov on 15.05.2023.
//

import SwiftUI

struct DoctorOrders: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    @State private var selectedDate: Date = Date()
    @State private var selectedDoctor: DBUser? = nil
    @State private var dayOrders: [(OrderModel, Bool)] = []
    @State private var isEditing: Bool = false
    @State private var showAlert: Bool = false
    @State private var noOrders: Bool? = nil
        
    var body: some View {
        VStack {
            BarTitle<EditButton, DoctorMenuPicker>(
                text: selectedDate.barTitleDate(),
                leftButton: selectedDoctor == vm.user ? EditButton(isEditing: $isEditing) : nil,
                rightButton: DoctorMenuPicker(
                    vm: vm,
                    doctors: vm.doctors.map(DoctorOption.user),
                    selectedDoctor: $selectedDoctor),
                action: { selectedDate = Date() }
            )
                        
            CustomDatePicker(
                selectedDate: $selectedDate,
                mode: .days,
                pastTime: true
            )
            
            if !(noOrders ?? false) {
                ScrollView {
                    LazyVStack {
                        ForEach($dayOrders, id: \.0.orderId) { order in
                            DoctorOrderRow(vm: vm, dayOrders: $dayOrders, order: order, isEditing: $isEditing, selectedDoctor: selectedDoctor, selectedDate: selectedDate)
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
                Text(selectedDate < Date() ? "There were no appointments on this day" : "You don't have any appointments yet")
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .onAppear {
            selectedDoctor = vm.user
        }
        .onChange(of: selectedDate) { _ in
            Task {
                let orders = try await vm.getDayMonthOrders(date: selectedDate, selectionMode: .day, doctorId: selectedDoctor?.userId)
                dayOrders = orders.map {($0, false)}
                isEditing = false
                if orders.isEmpty {
                    noOrders = true
                } else {
                    noOrders = false
                }
            }
        }
        .onChange(of: selectedDoctor) { _ in
            Task {
                let orders = try await vm.getDayMonthOrders(date: selectedDate, selectionMode: .day, doctorId: selectedDoctor?.userId)
                dayOrders = orders.map {($0, false)}
                isEditing = false
                if orders.isEmpty {
                    noOrders = true
                } else {
                    noOrders = false
                }
            }
        }
        .onChange(of: isEditing) { newValue in
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
}

struct DoctorOrders_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            DoctorOrders()
                .environmentObject(ProfileViewModel())
        }
        .padding(.horizontal, 20)
    }
}

struct DoctorMenuPicker: View {
    
    let vm: ProfileViewModel
    let doctors: [DoctorOption]
    @Binding var selectedDoctor: DBUser?
    
    var body: some View {
        Menu {
            ForEach(doctors, id: \.self) { doctorOption in
                switch doctorOption {
                case .allDoctors:
                    Button("Все доктора") {
                        selectedDoctor = nil
                    }
                case .user(let doctor):
                    Button("\(doctor.name ?? "") \(doctor.lastName ?? "")") {
                        selectedDoctor = doctor
                    }
                }
            }
        } label: {
            let doctor = selectedDoctor ?? vm.user
            ProfileImage(
                photoURL: doctor == selectedDoctor ? doctor?.photoUrl ?? "" : "",
                frame: ScreenSize.height * 0.06,
                color: Color.secondary.opacity(0.1),
                padding: 16
            )
            .buttonStyle(.plain)
            .cornerRadius(ScreenSize.width / 30)
        }
    }
}
