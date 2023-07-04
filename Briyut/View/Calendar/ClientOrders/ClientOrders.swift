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
            VStack {
                TopBar<Text, Text>(text: "appointments-string")
                
                CustomSegmentedPicker(
                    options: ["upcoming-string", "past-string"],
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
    }
}

struct ClientOrders_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ClientOrders()
                .environmentObject(ProfileViewModel())
        }
        .padding(.horizontal, 20)
    }
}

