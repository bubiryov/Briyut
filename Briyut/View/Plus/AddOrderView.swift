//
//  AddOrderView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 15.05.2023.
//

import SwiftUI
import FirebaseFirestore

struct AddOrderView: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    var doctor: DBUser? = nil
    var procedure: ProcedureModel? = nil
    @Binding var selectedTab: Tab
    
    var body: some View {
        VStack {
//
//            BarTitle<BackButton, Text>(text: "Test add", leftButton: BackButton())
//
//            Spacer()
//
//            Button {
//                let timestamp = Timestamp(date: Date())
//                let order = OrderModel(orderId: UUID().uuidString, procedureId: procedure?.procedureId ?? "", procedureName: procedure?.name ?? "", doctorId: doctor?.userId ?? "", doctorName: "\(doctor?.name ?? "") \(doctor?.lastName ?? "")", clientId: vm.user?.userId ?? "", date: timestamp, end: , isDone: false, price: procedure?.cost ?? 0)
//                Task {
//                    try await vm.addNewOrder(order: order)
//                    selectedTab = .home
//                }
//            } label: {
//                AccentButton(text: "Add order", isButtonActive: true)
//            }
//
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct AddOrderView_Previews: PreviewProvider {
    static var previews: some View {
        AddOrderView(selectedTab: .constant(.plus))
            .environmentObject(ProfileViewModel())
    }
}
