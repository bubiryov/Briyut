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
        
    var body: some View {
        VStack {
            BarTitle<EditButton, DoctorMenuPicker>(text: DateFormatter.customFormatter(format: "d MMMM yyyy").string(from: selectedDate), leftButton: selectedDoctor == vm.user ?  EditButton(isEditing: $isEditing) : nil, rightButton: DoctorMenuPicker(vm: vm, selectedDoctor: $selectedDoctor))
                        
            CustomDatePicker(selectedDate: $selectedDate, selectedTime: Binding(projectedValue: .constant("")))
            
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
        }
        .onAppear {
            selectedDoctor = vm.user
        }
        .onChange(of: selectedDate) { _ in
            Task {
                let orders = try await vm.getDayOrders(date: selectedDate, doctorId: selectedDoctor?.userId)
                dayOrders = orders.map {($0, false)}
            }
        }
        .onChange(of: selectedDoctor) { _ in
            Task {
                let orders = try await vm.getDayOrders(date: selectedDate, doctorId: selectedDoctor?.userId)
                dayOrders = orders.map {($0, false)}
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
    @Binding var selectedDoctor: DBUser?
    
    var body: some View {
        Menu {
            ForEach(vm.doctors, id: \.userId) { doctor in
                Button("\(doctor.name ?? "") \(doctor.lastName ?? "")") {
                    selectedDoctor = doctor
                }
            }
        } label: {
            ProfileImage(photoURL: selectedDoctor?.photoUrl ?? vm.user?.photoUrl ?? "", frame: ScreenSize.height * 0.06, color: Color.secondary.opacity(0.1))
                .buttonStyle(.plain)
                .cornerRadius(ScreenSize.width / 30)
        }
    }
}
