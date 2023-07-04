//
//  LeftLineCircleImage.swift
//  Briyut
//
//  Created by Egor Bubiryov on 03.07.2023.
//

import SwiftUI
import FirebaseFirestore

struct LeftLineCircleImage: View {
    
    var order: (OrderModel, Bool)
    
    var body: some View {
        VStack {
            Circle()
                .stroke(Color.mainColor, lineWidth: 1)
                .background(
                    order.1 ?
                    Circle()
                        .fill(Color.mainColor)
                        .padding(3) : nil
                )
                .frame(width: 20, height: 20)
            
            Rectangle()
                .fill(Color.mainColor)
                .frame(width: 3)
        }
    }
}

struct LeftLineCircleImage_Previews: PreviewProvider {
    static var previews: some View {
        LeftLineCircleImage(
            order: (OrderModel(
                orderId: "",
                procedureId: "",
                doctorId: "",
                clientId: "",
                date: Timestamp(date: Date()),
                end: Timestamp(date: Date()),
                isDone: false,
                price: 1000),
            true)
        )
    }
}
