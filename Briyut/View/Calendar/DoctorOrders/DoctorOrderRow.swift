//
//  DoctorOrderRow.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.06.2023.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DoctorOrderRow: View {
    
    let vm: ProfileViewModel
    @Binding var dayOrders: [(OrderModel, Bool)]
    @Binding var order: (OrderModel, Bool)
    @Binding var isEditing: Bool
    @State private var showAlert: Bool = false
    @State var fullCover: Bool = false
    var selectedDoctor: DBUser?
    var selectedDate: Date
            
    var body: some View {
        
        let procedure = vm.procedures.first(where: { $0.procedureId == order.0.procedureId })
        let client = vm.users.first(where: { $0.userId == order.0.clientId })
        
        HStack(alignment: .top) {
            LeftLineCircleImage(order: order)
            
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Text(procedure?.name ?? "Massage")
                        .font(Mariupol.medium, 20)
                        .foregroundColor(order.1 ? .white : .primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(DateFormatter.customFormatter(format: "HH:mm").string(from: order.0.date.dateValue()))
                        .foregroundColor(order.1 ? .white : .primary)
                        .font(order.1 ? Font.custom(Mariupol.bold.rawValue, size: 22) : Font.custom(Mariupol.regular.rawValue, size: 17))
                }
                
                Spacer()
                
                if order.1 {
                    Text("\(client?.name ?? client?.userId ?? "") \(client?.name != nil ? client?.lastName ?? "" : "")")
                        .font(Mariupol.regular, 14)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("₴ \(order.0.price)")
                        .font(Mariupol.medium, 17)
                        .foregroundColor(.white)
                }
                
                if isEditing && order.1 && order.0.end.dateValue() > Date() {
                    HStack {
                        Button {
                            Haptics.shared.notify(.warning)
                            Task {
                                showAlert = true
                            }
                        } label: {
                            Text("Cancel")
                                .foregroundColor(.black)
                                .font(Mariupol.medium, 17)
                                .frame(maxWidth: .infinity)
                                .frame(height: ScreenSize.height * 0.05)
                                .background(Color.white)
                                .cornerRadius(ScreenSize.width / 30)
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        Button {
                            fullCover.toggle()
                        } label: {
                            Text("Reschedule")
                                .foregroundColor(.black)
                                .font(Mariupol.medium, 17)
                                .frame(maxWidth: .infinity)
                                .frame(height: ScreenSize.height * 0.05)
                                .background(Color.white)
                                .cornerRadius(ScreenSize.width / 30)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, order.1 ? 10 : 0)
            .background(order.1 ? Color.mainColor : .clear)
            .cornerRadius(ScreenSize.width / 20)
            .padding(.leading)
            .opacity(order.0.end.dateValue() < Date() && !order.1 ? 0.5 : 1)
        }
        .padding(.leading, 2)
        .frame(maxHeight: ScreenSize.height * 0.21)
        .frame(minHeight: ScreenSize.height * 0.05)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                order.1.toggle()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Are you sure you want to remove the appointment?"),
                primaryButton: .destructive(Text("Remove"), action: {
                    Task {
                        try await vm.removeOrder(orderId: order.0.orderId)
                        let orders = try await vm.getDayMonthOrders(date: selectedDate, selectionMode: .day, doctorId: selectedDoctor?.userId)
                        withAnimation(.easeInOut(duration: 0.15)) {
                            dayOrders = orders.map {($0, false)}
                            isEditing = false
                        }
                    }
                }),
                secondaryButton: .default(Text("Cancel"), action: {
                })
            )
        }
        .sheet(isPresented: $fullCover) {
            DateTimeSelectionView(doctor: vm.user, order: order.0, mainButtonTitle: "Edit an appointment", selectedTab: .constant(.home))
                .padding()
                .padding(.bottom)
        }
        .onChange(of: fullCover) { newValue in
            if newValue == false {
                Task {
                    let orders = try await vm.getDayMonthOrders(date: selectedDate, selectionMode: .day, doctorId: selectedDoctor?.userId)
                    withAnimation(.easeInOut(duration: 0.15)) {
                        dayOrders = orders.map {($0, false)}
                        isEditing = false
                    }
                }
            }
        }
    }
}


struct DoctorOrderRow_Previews: PreviewProvider {
    static var previews: some View {
        let vm = ProfileViewModel()
        VStack {
            DoctorOrderRow(vm: vm, dayOrders: .constant([]), order: .constant(( OrderModel(orderId: "", procedureId: "", doctorId: "", clientId: "", date: Timestamp(date: Date()), end: Timestamp(date: Date()), isDone: false, price: 1000), false)), isEditing: .constant(true), selectedDoctor: nil, selectedDate: Date())
        }
        .padding(.horizontal, 20)
    }
}

struct LeftLineCircleImage: View {
    
    var order: (OrderModel, Bool)
    
    var body: some View {
        VStack {
            Circle()
                .stroke(Color.mainColor, lineWidth: 1)
                .background(
                    order.1 ?
                    Circle()
                        .fill(Color.mainColor)
                        .padding(3) : nil
                )
                .frame(width: 20, height: 20)
            
            Rectangle()
                .fill(Color.mainColor)
                .frame(width: 3)
        }
    }
}
