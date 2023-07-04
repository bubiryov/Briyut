//
//  OrderList.swift
//  Briyut
//
//  Created by Egor Bubiryov on 03.07.2023.
//

import SwiftUI

struct OrderList: View {
    
    let vm: ProfileViewModel
    var selectedIndex: Int
    var orderArray: [OrderModel]
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(orderArray, id: \.orderId) { order in
                    
                    OrderRow(
                        vm: vm,
                        order: order,
                        withButtons: order.isDone ? false : true,
                        color: nil,
                        fontColor: nil,
                        bigDate: false,
                        userInformation: .doctor,
                        photoBackgroundColor: Color.secondary.opacity(0.1)
                    )
                    
                    if order == orderArray.last {
                        HStack {
                            
                        }
                        .frame(height: 1)
                        .onAppear {
                            Task {
                                try await vm.getRequiredOrders(dataFetchMode: .user, isDone: selectedIndex == 0 ? false : true, countLimit: 6)
                            }
                        }
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .onAppear {
            Task {
                try await vm.getRequiredOrders(dataFetchMode: .user, isDone: selectedIndex == 0 ? false : true, countLimit: 6)
            }
        }
    }
}

struct OrderList_Previews: PreviewProvider {
    static var previews: some View {
        OrderList(vm: ProfileViewModel(), selectedIndex: 0, orderArray: [])
    }
}
