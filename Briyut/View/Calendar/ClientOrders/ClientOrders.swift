//
//  ClientOrders.swift
//  Briyut
//
//  Created by Egor Bubiryov on 15.05.2023.
//

import SwiftUI
import FirebaseFirestore

struct ClientOrders: View {
    
    @EnvironmentObject var interfaceData: InterfaceData
    @EnvironmentObject var mainViewModel: MainViewModel
    
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
                        interfaceData: interfaceData,
                        mainViewModel: mainViewModel,
                        selectedIndex: selectedIndex,
                        orderArray: interfaceData.activeOrders)
                    
                } else {
                    OrderList(
                        interfaceData: interfaceData,
                        mainViewModel: mainViewModel,
                        selectedIndex: selectedIndex,
                        orderArray: interfaceData.doneOrders
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
                .environmentObject(InterfaceData())
                .environmentObject(MainViewModel(data: InterfaceData()))
        }
        .padding(.horizontal, 20)
    }
}

