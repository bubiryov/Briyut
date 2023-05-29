//
//  ClientOrders.swift
//  Briyut
//
//  Created by Egor Bubiryov on 15.05.2023.
//

import SwiftUI
import FirebaseFirestore

struct ClientOrders: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    @State private var selectedIndex = 0
    @Binding var doneAnimation: Bool
    @Binding var selectedTab: Tab
    
    var body: some View {
        NavigationView {
            VStack {
                BarTitle<Text, Text>(text: "Appointments")
                
                CustomSegmentedPicker(options: ["Upcoming", "Recent"], selectedIndex: $selectedIndex)
                                
                if selectedIndex == 0 {
                    OrderList(vm: vm, selectedIndex: selectedIndex, orderArray: vm.activeOrders, doneAnimation: $doneAnimation, selectedTab: $selectedTab)
                } else {
                    OrderList(vm: vm, selectedIndex: selectedIndex, orderArray: vm.doneOrders, doneAnimation: $doneAnimation, selectedTab: $selectedTab)
                }
                
                Spacer()
            }
        }
    }
}

struct ClientOrders_Previews: PreviewProvider {
    static var previews: some View {
        ClientOrders(doneAnimation: .constant(false), selectedTab: .constant(.calendar))
            .environmentObject(ProfileViewModel())
    }
}

struct CustomSegmentedPicker: View {
    
    let options: [String]
    @Binding var selectedIndex: Int
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            HStack {
                RoundedRectangle(cornerRadius: ScreenSize.width / 30)
                    .frame(width: ScreenSize.width * 0.45)
                    .frame(height: ScreenSize.height * 0.06)
                    .foregroundColor(Color.mainColor)
            }
            .frame(maxWidth: .infinity, alignment: selectedIndex == 0 ? .leading : .trailing)
            
            HStack {
                ForEach(options.indices, id: \.self) { index in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedIndex = index
                        }
                    } label: {
                        Text(options[index])
                            .bold()
                            .foregroundColor(selectedIndex == index ? .white : .black)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .background(Color.secondaryColor)
        .frame(height: ScreenSize.height * 0.06)
        .cornerRadius(ScreenSize.width / 30)
    }
}

struct OrderList: View {
    
    let vm: ProfileViewModel
    var selectedIndex: Int
    var orderArray: [OrderModel]
    @Binding var doneAnimation: Bool
    @Binding var selectedTab: Tab
    
    var body: some View {
        List {
            ForEach(orderArray, id: \.orderId) { order in
                
                OrderRow(vm: vm, order: order, withButtons: order.isDone ? false : true, color: nil, fontColor: nil, doneAnimation: $doneAnimation, selectedTab: $selectedTab)
                    .listRowInsets(EdgeInsets())
                    .padding(.bottom, 7)
                
                if order == orderArray.last {
                    HStack {
                        
                    }
                    .frame(height: 1)
                    .onAppear {
                        Task {
                            try await vm.getAllClientOrders(isDone: selectedIndex == 0 ? false : true, countLimit: 6)
                        }
                    }
                }
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.inset)
        .scrollIndicators(.hidden)
        .onAppear {
            Task {
                try await vm.getAllClientOrders(isDone: selectedIndex == 0 ? false : true, countLimit: 6)
            }
        }
//        .refreshable {
//            vm.activeOrders = []
//            vm.doneOrders = []
//            vm.activeLastDocument = nil
//            vm.doneLastDocument = nil
//            Task {
//                try await vm.getAllOrders(isDone: false, countLimit: 6)
//                try await vm.getAllOrders(isDone: true, countLimit: 6)
//            }
//        }
    }
}
