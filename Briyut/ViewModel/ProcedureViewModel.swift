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
    let procedureManager: ProcedureManagerProtocol
    
    init(data: InterfaceData, orderViewModel: OrderViewModel, procedureManager: ProcedureManagerProtocol) {
        self.data = data
        self.orderViewModel = orderViewModel
        self.procedureManager = procedureManager
    }
    
    func addNewProcedure(procedure: ProcedureModel) async throws {
        try await procedureManager.createNewProcedure(procedure: procedure)
        try await getAllProcedures()
    }
        
    func getProcedure(procedureId: String) async throws -> ProcedureModel {
        try await procedureManager.getProduct(procedureId: procedureId)
    }
    
    func getAllProcedures() async throws {
        data.procedures = try await procedureManager.getAllProcedures()
    }
            
    func editProcedure(procedureId: String, name: String, duration: Int, cost: Int, parallelQuantity: Int, availableDoctors: [String]) async throws {
        try await procedureManager.editProcedure(procedureId: procedureId, name: name, duration: duration, cost: cost, parallelQuantity: parallelQuantity, availableDoctors: availableDoctors)
        try await getAllProcedures()
    }
    
    func removeProcedure(procedureId: String) async throws {
        try await procedureManager.removeProcedure(procedureId: procedureId)
        try await orderViewModel.deleteUnfinishedOrders(idType: .procedure, id: procedureId)
        try await getAllProcedures()
        data.activeLastDocument = nil
        data.activeOrders = []
        try await orderViewModel.getRequiredOrders(dataFetchMode: .user, isDone: false, countLimit: 2)
    }
    
    func updateProceduresForDoctor(userID: String) async throws {
        try await procedureManager.updateProceduresForDoctor(userID: userID)
    }

}
