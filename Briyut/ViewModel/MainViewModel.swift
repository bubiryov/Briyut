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
        let userManager = UserManager.shared
        let orderManager = OrderManager.shared
        let procedureManager = ProcedureManager.shared
        let authenticationManager = AuthenticationManager.shared
        let storageManager = StorageManager.shared
        
        self.data = data
        self.orderViewModel = OrderViewModel(data: data, orderManager: orderManager, procedureManager: procedureManager)
        self.procedureViewModel = ProcedureViewModel(data: data, orderViewModel: orderViewModel, procedureManager: procedureManager)
        self.profileViewModel = ProfileViewModel(data: data, procedureViewModel: procedureViewModel, orderViewModel: orderViewModel, userManager: userManager, authenticationManager: authenticationManager, storageManager: storageManager)
    }
}
