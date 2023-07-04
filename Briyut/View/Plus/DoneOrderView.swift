//
//  DoneOrderView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 06.06.2023.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import CachedAsyncImage

struct DoneOrderView: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    let order: OrderModel
    let withPhoto: Bool
    @Binding var selectedTab: Tab
    
    var body: some View {
        VStack {
            VStack {
                if withPhoto {
                    userPhoto
                } else {
                    DoneAnimation()
                        .frame(width: 250, height: 200)
                    Text("done-string")
                        .font(Mariupol.bold, 30)
                        .foregroundColor(.staticMainColor)
                }
            }
            .frame(minHeight: ScreenSize.height * 0.4, maxHeight: .infinity)
            .frame(maxWidth: .infinity)
            .background(Color.secondaryColor)
            .cornerRadius(ScreenSize.width / 20)
            
            VStack(spacing: ScreenSize.height * 0.02) {
                let specialist = vm.doctors.first(where: { $0.userId == order.doctorId })
                let client = vm.users.first(where: { $0.userId == order.clientId })
                                
                DoneOrderViewRow(
                    leftText: "date-string",
                    rightText: DateFormatter.customFormatter(format: "dd MMM yyyy").string(from: order.date.dateValue()))
                                
                DoneOrderViewRow(
                    leftText: "time-string",
                    rightText: DateFormatter.customFormatter(format: "HH:mm").string(from: order.date.dateValue()))
                                
                DoneOrderViewRow(
                    leftText: "specialist-string",
                    rightText: "\(specialist?.name ?? "deleted-specialist-string".localized) \((specialist?.name != nil) ? specialist?.lastName ?? "" : "")")
                
                if vm.user?.isDoctor ?? false {
                    DoneOrderViewRow(
                        leftText: "client-string",
                        rightText: "\(client?.name ?? "\(client?.userId ?? "deleted-user-string".localized)") \((client?.name != nil) ? client?.lastName ?? "" : "")")
                }
                
                DoneOrderViewRow(
                    leftText: "total-string",
                    rightText: "₴ \(order.price)")
                
            }
            .padding(20)
            .frame(minHeight: ScreenSize.height * 0.135)
            .frame(maxWidth: .infinity)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(ScreenSize.width / 20)
                        
            Button {
                withAnimation {
                    presentationMode.wrappedValue.dismiss()
                    if !withPhoto {
                        selectedTab = .home
                    }
                }
            } label: {
                AccentButton(text: withPhoto ? "back-string" : "back-home-string", isButtonActive: true)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .background(Color.backgroundColor)
        .navigationBarBackButtonHidden()
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.height > 100 && withPhoto {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        )
    }
}

struct DoneOrderView_Previews: PreviewProvider {
    static var previews: some View {
        DoneOrderView(order: OrderModel(orderId: "", procedureId: "", doctorId: "", clientId: "", date: Timestamp(date: Date()), end: Timestamp(date: Date()), isDone: false, price: 1000), withPhoto: true, selectedTab: .constant(.plus))
            .environmentObject(ProfileViewModel())
    }
}

fileprivate struct DoneOrderViewRow: View {
    
    let leftText: String
    let rightText: String
    
    var body: some View {
        HStack {
            Text(leftText.localized)
                .foregroundColor(.secondary)
                .font(Mariupol.regular, 17)
            
            Spacer()
            
            Text(rightText)
                .font(Mariupol.medium, 17)
                .lineLimit(1)
                .padding(.leading, 50)
        }
    }
}

extension DoneOrderView {
    var userPhoto: some View {
        let userPhotoUrl: String = {
            if vm.user?.isDoctor ?? false {
                return vm.users.first(where: { $0.userId == order.clientId })?.photoUrl ?? ""
            } else {
                return vm.doctors.first(where: { $0.userId == order.doctorId })?.photoUrl ?? ""
            }
        }()
        
        return GeometryReader { geometry in
            CachedAsyncImage(url: URL(string: userPhotoUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            } placeholder: {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .foregroundColor(.staticMainColor)
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        }

    }
}
