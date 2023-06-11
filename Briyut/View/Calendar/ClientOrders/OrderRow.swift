//
//  OrderRow.swift
//  Briyut
//
//  Created by Egor Bubiryov on 27.05.2023.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

enum UserStatus {
    case client
    case doctor
}

struct OrderRow: View {
    
    let vm: ProfileViewModel
    let order: OrderModel
    let withButtons: Bool
    let color: Color?
    let fontColor: Color?
    let bigDate: Bool
    let userInformation: UserStatus
    let photoBackgroundColor: Color
    @State private var showAlert: Bool = false
    @State var rescheduleFullCover: Bool = false
    @State private var showFullOrder: Bool = false
    
    var body: some View {
        
        VStack(spacing: 15) {
            HStack {
                let doc = vm.doctors.first(where: { $0.userId == order.doctorId })
                let procedure = vm.procedures.first(where: { $0.procedureId == order.procedureId })
                let user = vm.users.first(where: { $0.userId == order.clientId })
                
                ProfileImage(
                    photoURL: userInformation == .client ? user?.photoUrl : doc?.photoUrl,
                    frame: ScreenSize.height * 0.1,
                    color: photoBackgroundColor
                )
                    .cornerRadius(ScreenSize.width / 20)
                
                VStack(alignment: .leading) {
                    
                    Text(procedure?.name ?? "")
                        .font(.title3.bold())
                        .lineLimit(1)
                        .foregroundColor(fontColor != nil ? fontColor : .primary)

                    Spacer()
                                        
                    if userInformation == .client {
                        Text("\(user?.name ?? "") \(user?.lastName ?? "")")
                            .font(.subheadline)
                            .foregroundColor(fontColor != nil ? fontColor : .secondary)
                    } else {
                        Text("\(doc?.name ?? "") \(doc?.lastName ?? "")")
                            .font(.subheadline)
                            .foregroundColor(fontColor != nil ? fontColor : .secondary)
                    }

                    
                    Spacer()
                    
                    Text(DateFormatter.customFormatter(format: "dd MMM yyyy, HH:mm").string(from: order.date.dateValue()))
                        .font(bigDate ? .title3.bold() : .subheadline.bold())
                        .foregroundColor(fontColor != nil ? fontColor : .primary)
                    
                }
                .padding(.leading, 5)
                .padding(.vertical, 10)
                .frame(height: ScreenSize.height * 0.1)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if withButtons {
                HStack {
                    Button {
                        Task {
                            showAlert = true
                        }
                    } label: {
                        Text("Cancel")
                            .foregroundColor(.black)
                            .font(.headline.bold())
                            .frame(height: ScreenSize.height * 0.055)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(ScreenSize.width / 30)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Button {
                        rescheduleFullCover.toggle()
                    } label: {
                        Text("Reschedule")
                            .foregroundColor(.white)
                            .font(.headline.bold())
                            .frame(height: ScreenSize.height * 0.055)
                            .frame(maxWidth: .infinity)
                            .background(Color.mainColor)
                            .cornerRadius(ScreenSize.width / 30)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 7)
        .frame(height: !withButtons ? ScreenSize.height * 0.14 : ScreenSize.height * 0.21)
        .background(color == nil ? (order.isDone ? Color.secondary.opacity(0.1) : Color.secondaryColor) : color)
        .cornerRadius(ScreenSize.width / 20)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Are you sure you want to remove the appointment?"),
                primaryButton: .destructive(Text("Remove"), action: {
                    Task {
//                        vm.activeOrders = []
//                        vm.activeLastDocument = nil
                        try await vm.removeOrder(orderId: order.orderId)
                    }
                }),
                secondaryButton: .default(Text("Cancel"), action: {
                    
                })
            )
        }
        .sheet(isPresented: $rescheduleFullCover) {
            let doctor = vm.doctors.first(where: { $0.userId == order.doctorId })
            DateTimeSelectionView(doctor: doctor, order: order, mainButtonTitle: "Edit an appoinment", selectedTab: .constant(.calendar))
                .padding()
                .padding(.bottom)
        }
        .onTapGesture {
            showFullOrder = true
        }
        .fullScreenCover(isPresented: $showFullOrder) {
            DoneOrderView(order: order, withPhoto: true, selectedTab: .constant(.calendar))
        }
    }
    
//    func orderDate() -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd MMM yyyy, HH:mm"
//        return dateFormatter.string(from: order.date.dateValue())
//    }
    
}

struct OrderRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            OrderRow(vm: ProfileViewModel(), order: OrderModel(orderId: "", procedureId: "", doctorId: "hJlNBE2L1RWTDLNzvZNQIf4g6Ry1", clientId: "", date: Timestamp(date: Date()), end: Timestamp(date: Date()), isDone: false, price: 900), withButtons: false, color: .secondaryColor, fontColor: .black, bigDate: false, userInformation: .client, photoBackgroundColor: .secondary.opacity(0.1))
        }
        .padding(.horizontal, 20)
    }
}
