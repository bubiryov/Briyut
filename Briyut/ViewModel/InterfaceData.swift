//
//  InterfaceData.swift
//  Briyut
//
//  Created by Egor Bubiryov on 07.07.2023.
//

import Foundation
import FirebaseFirestore

@MainActor
class InterfaceData: ObservableObject {
    
    @Published var user: DBUser? = nil
    @Published var doctors: [DBUser] = []
    @Published var users: [DBUser] = []
    @Published var procedures: [ProcedureModel] = []
    @Published var authProviders: [AuthProviderOption] = []
    @Published var activeOrders: [OrderModel] = []
    @Published var doneOrders: [OrderModel] = []
    @Published var allOrders: [OrderModel] = []

    var activeLastDocument: DocumentSnapshot? = nil
    var doneLastDocument: DocumentSnapshot? = nil
    var allLastDocument: DocumentSnapshot? = nil
}
