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
        
        let interfaceData = InterfaceData()

        VStack {
            ClientOrders()
                .environmentObject(interfaceData)
                .environmentObject(MainViewModel(data: interfaceData))
        }
        .padding(.horizontal, 20)
    }
}

