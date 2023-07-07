//
//  ProcedureViewModel.swift
//  Briyut
//
//  Created by Egor Bubiryov on 07.07.2023.
//

import Foundation

@MainActor
class ProcedureViewModel {
    
    let data: InterfaceData
    let orderViewModel: OrderViewModel
    
    init(data: InterfaceData, orderViewModel: OrderViewModel) {
        self.data = data
        self.orderViewModel = orderViewModel
    }
    
    func addNewProcedure(procedure: ProcedureModel) async throws {
        try await ProcedureManager.shared.createNewProcedure(procedure: procedure)
        try await getAllProcedures()
    }
        
    func getProcedure(procedureId: String) async throws -> ProcedureModel {
        try await ProcedureManager.shared.getProduct(procedureId: procedureId)
    }
    
    func getAllProcedures() async throws {
        data.procedures = try await ProcedureManager.shared.getAllProcedures()
    }
            
    func editProcedure(procedureId: String, name: String, duration: Int, cost: Int, parallelQuantity: Int, availableDoctors: [String]) async throws {
        try await ProcedureManager.shared.editProcedure(procedureId: procedureId, name: name, duration: duration, cost: cost, parallelQuantity: parallelQuantity, availableDoctors: availableDoctors)
        try await getAllProcedures()
    }
    
    func removeProcedure(procedureId: String) async throws {
        try await ProcedureManager.shared.removeProcedure(procedureId: procedureId)
        try await orderViewModel.deleteUnfinishedOrders(idType: .procedure, id: procedureId)
        try await getAllProcedures()
        data.activeLastDocument = nil
        data.activeOrders = []
        try await orderViewModel.getRequiredOrders(dataFetchMode: .user, isDone: false, countLimit: 2)
    }
    
    func updateProceduresForDoctor(userID: String) async throws {
        try await ProcedureManager.shared.updateProceduresForDoctor(userID: userID)
    }

}
