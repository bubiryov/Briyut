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
    
    var body: some View {
        VStack {
            BarTitle<BackButton, Text>(text: "History", leftButton: BackButton())
            
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
                            photoBackgroundColor: Color.secondary.opacity(0.1)
                        )
                        
                        if order == vm.allOrders.last {
                            HStack {
                                
                            }
                            .frame(height: 1)
                            .onAppear {
                                Task {
                                    try await vm.getAllOrders()
                                }
                            }
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .onAppear {
                Task {
                    try await vm.getAllOrders()
                }
            }
            Spacer()
        }
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

    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HistoryView()
                .environmentObject(ProfileViewModel())
        }
        .padding(.horizontal, 20)
    }
}
