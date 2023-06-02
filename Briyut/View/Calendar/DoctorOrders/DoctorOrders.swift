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
    @State private var dayOrders: [OrderModel] = []
    @State private var mediumSizeArray: [Bool] = []
    
    var body: some View {
        VStack {
            BarTitle<Text, DoctorMenuPicker>(text: DateFormatter.customFormatter(format: "d MMMM yyyy").string(from: selectedDate), rightButton: DoctorMenuPicker(vm: vm, selectedDoctor: $selectedDoctor))
                        
            CustomDatePicker(selectedDate: $selectedDate, selectedTime: Binding(projectedValue: .constant("")))
                        
            ScrollView {
                LazyVStack {
                    ForEach(dayOrders, id: \.orderId) { order in
                        DoctorOrderRow(vm: vm, dayOrders: dayOrders, order: order, mediumSizeArray: $mediumSizeArray)
                            .onAppear {
                                if let index = dayOrders.firstIndex(where: { $0.date.dateValue() < Date() && $0.end.dateValue() > Date() }) {
                                    mediumSizeArray[index] = true
                                }
                            }
                    }
                }
                .padding(.top)
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            selectedDoctor = vm.user
        }
        .onChange(of: selectedDate) { _ in
            Task {
                dayOrders = try await vm.getDayOrders(date: selectedDate, doctorId: selectedDoctor?.userId)
                mediumSizeArray = Array(repeating: false, count: dayOrders.count)
            }
        }
        .onChange(of: selectedDoctor) { _ in
            Task {
                dayOrders = try await vm.getDayOrders(date: selectedDate, doctorId: selectedDoctor?.userId)
                mediumSizeArray = Array(repeating: false, count: dayOrders.count)
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
