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
                            photoBackgroundColor: .clear
                        )
                        
                        
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
