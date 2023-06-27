//
//  OrderRow.swift
//  Briyut
//
//  Created by Egor Bubiryov on 27.05.2023.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

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
        
        VStack(spacing: 10) {
            HStack {
                let doc = vm.doctors.first(where: { $0.userId == order.doctorId })
                let procedure = vm.procedures.first(where: { $0.procedureId == order.procedureId })
                let user = vm.users.first(where: { $0.userId == order.clientId })
                
                ProfileImage(
                    photoURL: userInformation == .client ? user?.photoUrl : doc?.photoUrl,
                    frame: ScreenSize.height * 0.1,
                    color: photoBackgroundColor,
                    padding: 16
                )
                    .cornerRadius(ScreenSize.width / 20)
                
                VStack(alignment: .leading) {
                    
                    Text(procedure?.name ?? "Deleted procedure")
                        .font(Mariupol.medium, 20)
                        .lineLimit(1)
                        .foregroundColor(fontColor != nil ? fontColor : .primary)

                    Spacer()
                                        
                    if userInformation == .client {
                        Text("\(user?.name ?? "\(user?.userId ?? "Deleted user")") \(((user?.name) != nil) ? user?.lastName ?? "" : "")")
                            .font(Mariupol.regular, 14)
                            .foregroundColor(fontColor != nil ? fontColor : .secondary)
                    } else {
                        Text("\(doc?.name ?? "\(doc?.userId ?? "Deleted specialist")") \(doc?.lastName ?? "")")
                            .font(Mariupol.regular, 14)
                            .foregroundColor(fontColor != nil ? fontColor : .secondary)
                    }

                    
                    Spacer()
                    
                    Text(DateFormatter.customFormatter(format: "dd MMM yyyy, HH:mm").string(from: order.date.dateValue()))
                        .font(bigDate ? Font.custom(Mariupol.medium.rawValue, size: 22) : Font.custom(Mariupol.medium.rawValue, size: 17))

                        .foregroundColor(fontColor != nil ? fontColor : .primary)
                    
                }
                .padding(.leading, 10)
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
                            .font(Mariupol.medium, 17)
                            .frame(height: ScreenSize.height * 0.05)
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
                            .font(Mariupol.medium, 17)
                            .frame(height: ScreenSize.height * 0.05)
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
        .frame(height: withButtons ? ScreenSize.height * 0.2 : ScreenSize.height * 0.135)
        .background(color == nil ? (order.isDone ? Color.secondary.opacity(0.1) : Color.secondaryColor) : color)
        .cornerRadius(ScreenSize.width / 20)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Are you sure you want to remove the appointment?"),
                primaryButton: .destructive(Text("Remove"), action: {
                    Task {
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
            OrderRow(vm: ProfileViewModel(), order: OrderModel(orderId: "", procedureId: "", doctorId: "hJlNBE2L1RWTDLNzvZNQIf4g6Ry1", clientId: "", date: Timestamp(date: Date()), end: Timestamp(date: Date()), isDone: false, price: 900), withButtons: false, color: .mainColor, fontColor: .white, bigDate: true, userInformation: .doctor, photoBackgroundColor: .white.opacity(0.2))
        }
        .padding(.horizontal, 20)
    }
}
