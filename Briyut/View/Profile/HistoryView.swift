//
//  HistoryView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 08.06.2023.
//

import SwiftUI

struct HistoryView: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var loading: Bool = false
    @State private var showAlert: Bool = false
    @State private var choosenOrder: OrderModel? = nil
    @State private var showSheet: Bool = false
    
    var body: some View {
        VStack {
            TopBar<BackButton, AddButton>(
                text: "history-string",
                leftButton: BackButton(),
                rightButton: AddButton(showSheet: $showSheet)
            )
                        
            ScrollView {
                LazyVStack {
                    ForEach(vm.allOrders, id: \.orderId) { order in
                        
                        OrderRow(
                            vm: vm,
                            order: order,
                            withButtons: false,
                            color: nil,
                            fontColor: nil,
                            bigDate: false,
                            userInformation: .doctor,
                            photoBackgroundColor: .clear
                        )
                        .contextMenu {
                            if order.isDone {
                                Button(role: .destructive) {
                                    choosenOrder = order
                                    showAlert = true
                                } label: {
                                    Text("remove-string")
                                }
                            }
                        }
                        
                        if order == vm.allOrders.last {
                            HStack {
                                
                            }
                            .frame(height: 1)
                            .onAppear {
                                Task {
                                    do {
                                        loading = true
                                        try await vm.getAllOrders(dataFetchMode: .all, count: 10, isDone: nil)
                                        loading = false
                                    } catch {
                                        loading = true
                                    }
                                }
                            }
                            
                            if loading {
                                ProgressView()
                                    .tint(.mainColor)
                            }
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .onAppear {
                Task {
                    try await vm.getAllOrders(dataFetchMode: .all, count: 10, isDone: nil)
                }
            }
            Spacer()
        }
        .background(Color.backgroundColor)
        .onDisappear {
            vm.allOrders = []
            vm.allLastDocument = nil
        }
        .navigationBarBackButtonHidden()
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onEnded { gesture in
                if gesture.translation.width > 100 {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        )
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("remove-appointment-alert-title-string"),
                primaryButton: .destructive(Text("remove-string"), action: {
                    removeAppointment()
                }),
                secondaryButton: .default(Text("cancel-string"), action: { })
            )
        }
        .sheet(isPresented: $showSheet) {
            AddPastOrderView()
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HistoryView()
                .environmentObject(ProfileViewModel())
        }
        .padding(.horizontal, 20)
        .background(Color.backgroundColor)
    }
}

extension HistoryView {
    func removeAppointment() {
        Task {
            do {
                guard let choosenOrder else {
                    throw URLError(.badServerResponse)
                }
                try await vm.removeOrder(orderId: choosenOrder.orderId)
                vm.allLastDocument = nil
                vm.allOrders = []
                try await vm.getAllOrders(dataFetchMode: .all, count: 10, isDone: nil)
            } catch {
                print("Something went wrong")
            }
        }
    }
}
