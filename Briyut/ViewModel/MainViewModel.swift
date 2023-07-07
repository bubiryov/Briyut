//
//  MainViewModel.swift
//  Briyut
//
//  Created by Egor Bubiryov on 07.07.2023.
//

import Foundation

@MainActor
class MainViewModel: ObservableObject {
    let data: InterfaceData
    let procedureViewModel: ProcedureViewModel
    let orderViewModel: OrderViewModel
    let profileViewModel: ProfileViewModel
    
    init(data: InterfaceData) {
        self.data = data
        self.orderViewModel = OrderViewModel(data: data)
        self.procedureViewModel = ProcedureViewModel(data: data, orderViewModel: orderViewModel)
        self.profileViewModel = ProfileViewModel(data: data, procedureViewModel: procedureViewModel, orderViewModel: orderViewModel)
    }
}
