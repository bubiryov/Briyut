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
    
    let interfaceData: InterfaceData
    let mainViewModel: MainViewModel
    @Binding var dayOrders: [(OrderModel, Bool)]
    @Binding var order: (OrderModel, Bool)
    @Binding var isEditing: Bool
    @State private var showAlert: Bool = false
    @State var fullCover: Bool = false
    var selectedDoctor: DBUser?
    var selectedDate: Date
            
    var body: some View {
        
        let procedure = interfaceData.procedures.first(where: { $0.procedureId == order.0.procedureId })
        let client = interfaceData.users.first(where: { $0.userId == order.0.clientId })
        
        HStack(alignment: .top) {
            LeftLineCircleImage(order: order)
            
            VStack(alignment: .leading) {
                
                doctorOrderRowHeader(for: procedure)

                Spacer()
                
                if order.1 {
                    Text("\(client?.name ?? client?.userId ?? "Deleted user") \(client?.name != nil ? client?.lastName ?? "" : "")")
                        .font(Mariupol.regular, 14)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("₴ \(order.0.price)")
                        .font(Mariupol.medium, 17)
                        .foregroundColor(.white)
                }
                
                if isEditing && order.1 && order.0.end.dateValue() > Date() {
                    doctorOrderRowEditingButtons
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
                title: Text("cancel-appointment-alert-string"),
                primaryButton: .destructive(Text("remove-string"), action: {
                    Task {
                        try await mainViewModel.orderViewModel.removeOrder(orderId: order.0.orderId)
                        let orders = try await mainViewModel.orderViewModel.getDayMonthOrders(date: selectedDate, selectionMode: .day, doctorId: selectedDoctor?.userId, firstDate: nil, secondDate: nil)
                        withAnimation(.easeInOut(duration: 0.15)) {
                            dayOrders = orders.map {($0, false)}
                            isEditing = false
                        }
                    }
                }),
                secondaryButton: .default(Text("cancel-string"), action: {})
            )
        }
        .sheet(isPresented: $fullCover) {
            DateTimeSelectionView(
                doctor: interfaceData.user,
                order: order.0,
                mainButtonTitle: "edit-appointment-string".localized,
                selectedTab: .constant(.home)
            )
            .padding()
            .padding(.bottom)
            .background(Color.backgroundColor)
        }
        .onChange(of: fullCover) { newValue in
            fullCoverUpdatingOrders(newValue)
        }
    }
}


struct DoctorOrderRow_Previews: PreviewProvider {
    static var previews: some View {
//        let vm = ProfileViewModel()
        VStack {
            DoctorOrderRow(interfaceData: InterfaceData(), mainViewModel: MainViewModel(data: InterfaceData()), dayOrders: .constant([]), order: .constant(( OrderModel(orderId: "", procedureId: "", doctorId: "", clientId: "", date: Timestamp(date: Date()), end: Timestamp(date: Date()), isDone: false, price: 1000), false)), isEditing: .constant(true), selectedDoctor: nil, selectedDate: Date())
        }
        .padding(.horizontal, 20)
    }
}

// MARK: Components

extension DoctorOrderRow {
    
    private func doctorOrderRowHeader(for procedure: ProcedureModel?) -> some View {
        HStack(alignment: .top) {
            Text(procedure?.name ?? "deleted-procedure-string".localized)
                .font(Mariupol.medium, 20)
                .foregroundColor(order.1 ? .white : .primary)
                .lineLimit(1)
            
            Spacer()
            
            Text(DateFormatter.customFormatter(format: "HH:mm").string(from: order.0.date.dateValue()))
                .foregroundColor(order.1 ? .white : .primary)
                .font(order.1 ? Font.custom(Mariupol.bold.rawValue, size: 22) : Font.custom(Mariupol.regular.rawValue, size: 17))
        }
    }
    
    var doctorOrderRowEditingButtons: some View {
        HStack {
            Button {
                Haptics.shared.notify(.warning)
                Task {
                    showAlert = true
                }
            } label: {
                Text("cancel-string")
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
                Text("reschedule-string")
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

// MARK: Functions

extension DoctorOrderRow {
    
    private func fullCoverUpdatingOrders(_ newValue: Bool) {
        if newValue == false {
            Task {
                do {
                    let orders = try await mainViewModel.orderViewModel.getDayMonthOrders(date: selectedDate, selectionMode: .day, doctorId: selectedDoctor?.userId, firstDate: nil, secondDate: nil)
                    withAnimation(.easeInOut(duration: 0.15)) {
                        dayOrders = orders.map {($0, false)}
                        isEditing = false
                    }
                } catch {
                    print("Full cover updating orders error \(error)")
                }
            }
        }
    }
}
