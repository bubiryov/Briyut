//
//  DoctorOrderRow.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.06.2023.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

//struct DoctorOrderRow: View {
//
//    let vm: ProfileViewModel
//    var dayOrders: [OrderModel]
//    var order: OrderModel
//    @Binding var mediumSizeArray: [Bool]
//
//    var body: some View {
//        let orderIndex = dayOrders.firstIndex(where: { order.orderId == $0.orderId })
//        let client = vm.users.first(where: { $0.userId == dayOrders[orderIndex ?? 0].clientId })
//        let procedure = vm.procedures.first(where: { $0.procedureId == dayOrders[orderIndex ?? 0].procedureId })
//
//        if !mediumSizeArray.isEmpty {
//
//            let index = mediumSizeArray.indices.first(where: { $0 == orderIndex })!
//
//            HStack {
//                VStack {
//
//                    Circle()
//                        .stroke(Color.mainColor, lineWidth: 1)
//                        .background(
//                            mediumSizeArray[index] ?
//                            Circle()
//                                .fill(Color.mainColor)
//                                .padding(3) : nil
//                        )
//                        .frame(width: 20, height: 20)
//
//                    Rectangle()
//                        .fill(Color.mainColor)
//                        .frame(width: 3)
//                }
////                .background(Color.red)
//
//                HStack(alignment: .top) {
//
//                    VStack(alignment: .leading) {
//
//                        Text(procedure?.name ?? "Massage")
//                            .font(.title3.bold())
//                            .lineLimit(1)
//                            .foregroundColor(mediumSizeArray[index] ? .white : .primary)
//
//                        if mediumSizeArray[index] {
//
//                            Spacer()
//
//                            Text("\(client?.name ?? "Alex") \(client?.lastName ?? "Shevchenko")")
//                                .font(.subheadline.bold())
//                                .foregroundColor(.white)
//
//                            Spacer()
//
//                            Text("₴ \(procedure?.cost ?? 1000)")
//                                .font(.subheadline.bold())
//                                .foregroundColor(.white)
//                        }
//                    }
//
//                    Spacer()
//
//                    Text(DateFormatter.customFormatter(format: "HH:mm").string(from: dayOrders[index].date.dateValue()))
//                        .foregroundColor(mediumSizeArray[index] ? .white : .primary)
//                        .font(mediumSizeArray[index] ? .title2.bold() : .body)
//
//                }
//                .padding()
//                .frame(height: mediumSizeArray[index] ? ScreenSize.height * 0.12 : ScreenSize.height * 0.05)
//                .background(mediumSizeArray[index] ? Color.mainColor : .clear)
//                .cornerRadius(ScreenSize.width / 20)
//                .padding(.leading)
//                .opacity(dayOrders[index].end.dateValue() < Date() && !mediumSizeArray[index] ? 0.5 : 1)
//            }
//            .contentShape(Rectangle())
//            .onTapGesture {
//                withAnimation(.easeInOut(duration: 0.2)) {
//                    mediumSizeArray[index].toggle()
//                }
//            }
//            .frame(height: mediumSizeArray[index] ? ScreenSize.height * 0.13 : ScreenSize.height * 0.05)
////            .background(Color.yellow)
//        }
//    }
//}

struct DoctorOrderRow: View {
    
    let vm: ProfileViewModel
    var dayOrders: [OrderModel]
    var order: OrderModel
    @Binding var mediumSizeArray: [Bool]
            
    var body: some View {
        let orderIndex = dayOrders.firstIndex(where: { order.orderId == $0.orderId })
        let client = vm.users.first(where: { $0.userId == dayOrders[orderIndex ?? 0].clientId })
        let procedure = vm.procedures.first(where: { $0.procedureId == dayOrders[orderIndex ?? 0].procedureId })
                
        if !mediumSizeArray.isEmpty {
            
            let index = mediumSizeArray.indices.first(where: { $0 == orderIndex })!
            
            VStack {
                HStack {
                    VStack {
                        
                        Circle()
                            .stroke(Color.mainColor, lineWidth: 1)
                            .background(
                                mediumSizeArray[index] ?
                                Circle()
                                    .fill(Color.mainColor)
                                    .padding(3) : nil
                            )
                            .frame(width: 20, height: 20)
                        
                        Rectangle()
                            .fill(Color.mainColor)
                            .frame(width: 3)
                    }
                    
                    HStack(alignment: .top) {
                        
                        VStack(alignment: .leading) {
                            
                            Text(procedure?.name ?? "Massage")
                                .font(.title3.bold())
                                .lineLimit(1)
                                .foregroundColor(mediumSizeArray[index] ? .white : .primary)
                            
                            if mediumSizeArray[index] {
                                
                                Spacer()
                                
                                Text("\(client?.name ?? "Alex") \(client?.lastName ?? "Shevchenko")")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("₴ \(procedure?.cost ?? 1000)")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Spacer()
                        
                        Text(DateFormatter.customFormatter(format: "HH:mm").string(from: dayOrders[index].date.dateValue()))
                            .foregroundColor(mediumSizeArray[index] ? .white : .primary)
                            .font(mediumSizeArray[index] ? .title2.bold() : .body)
                        
                    }
                    .padding()
                    .frame(height: mediumSizeArray[index] ? ScreenSize.height * 0.12 : ScreenSize.height * 0.05)
                    .padding(.leading)
                    .opacity(dayOrders[index].end.dateValue() < Date() && !mediumSizeArray[index] ? 0.5 : 1)
                }
                .background(mediumSizeArray[index] ? Color.mainColor : .clear)
                .cornerRadius(ScreenSize.width / 20)

                Text("Hello")
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    mediumSizeArray[index].toggle()
                }
            }
            .frame(height: mediumSizeArray[index] ? ScreenSize.height * 0.13 : ScreenSize.height * 0.05)
        }
    }
}


struct DoctorOrderRow_Previews: PreviewProvider {
    static var previews: some View {
        let vm = ProfileViewModel()

        DoctorOrderRow(vm: vm, dayOrders: [], order: OrderModel(orderId: "", procedureId: "", doctorId: "", clientId: "", date: Timestamp(date: Date()), end: Timestamp(date: Date()), isDone: false, price: 900), mediumSizeArray: .constant([false]))
    }
}
