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
    
    var body: some View {
//        NavigationView {
            VStack {
                BarTitle<Text, Text>(text: "Appointments")
                
                CustomSegmentedPicker(
                    options: ["Upcoming", "Past"],
                    selectedIndex: $selectedIndex
                )
                                
                if selectedIndex == 0 {
                    OrderList(
                        vm: vm,
                        selectedIndex: selectedIndex,
                        orderArray: vm.activeOrders)
                    
                } else {
                    OrderList(
                        vm: vm,
                        selectedIndex: selectedIndex,
                        orderArray: vm.doneOrders
                    )
                }
            }
            .background(Color.backgroundColor)
//        }
    }
}

struct ClientOrders_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ClientOrders()
                .environmentObject(ProfileViewModel())
        }
        .padding(.horizontal, 20)
//        .background(Color.backgroundColor)
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
                            .font(Mariupol.medium, 17)
                            .foregroundColor(selectedIndex == index ? .white : .primary)
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
