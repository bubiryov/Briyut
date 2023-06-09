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
                    let userPhotoUrl: String = {
                        if vm.user?.isDoctor ?? false {
                            return vm.users.first(where: { $0.userId == order.clientId })?.photoUrl ?? ""
                        } else {
                            return vm.doctors.first(where: { $0.userId == order.doctorId })?.photoUrl ?? ""
                        }
                    }()
                    GeometryReader { geometry in
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
                                .foregroundColor(.mainColor)
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                    }
                } else {
                    DoneAnimation()
                        .frame(width: 250, height: 200)
                    
                    Text("Done")
                        .font(.largeTitle.bold())
                        .foregroundColor(.mainColor)
                }
            }
            .frame(minHeight: ScreenSize.height * 0.4, maxHeight: ScreenSize.height * 0.6)
            .frame(maxWidth: .infinity)
            .background(Color.secondaryColor)
            .cornerRadius(ScreenSize.width / 20)
            
            VStack {
                let specialist = vm.doctors.first(where: { $0.userId == order.doctorId })
                let client = vm.users.first(where: { $0.userId == order.clientId })
                
                Spacer()
                
                DoneOrderViewRow(leftText: "Date", rightText: DateFormatter.customFormatter(format: "dd MMM yyyy").string(from: order.date.dateValue()))
                
                Spacer()
                
                DoneOrderViewRow(leftText: "Time", rightText: DateFormatter.customFormatter(format: "HH:mm").string(from: order.date.dateValue()))
                
                Spacer()
                
                DoneOrderViewRow(leftText: "Specialist", rightText: "\(specialist?.name ?? "") \(specialist?.lastName ?? "")")
                
                Spacer()
                
                if vm.user?.isDoctor ?? false {
                    DoneOrderViewRow(leftText: "Client", rightText: "\(client?.name ?? "") \(client?.lastName ?? "")")
                    
                    Spacer()
                }
                
                DoneOrderViewRow(leftText: "Total", rightText: "₴ \(order.price)")
                
                Spacer()
                
            }
            .padding(.horizontal, 20)
            .frame(height: ScreenSize.height * 0.25)
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
                AccentButton(text: withPhoto ? "Back" : "Back Home", isButtonActive: true)
            }
            .padding(.top, 10)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
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
        DoneOrderView(order: OrderModel(orderId: "", procedureId: "", doctorId: "", clientId: "", date: Timestamp(date: Date()), end: Timestamp(date: Date()), isDone: false, price: 1000), withPhoto: false, selectedTab: .constant(.plus))
            .environmentObject(ProfileViewModel())
    }
}

fileprivate struct DoneOrderViewRow: View {
    
    let leftText: String
    let rightText: String
    
    var body: some View {
        HStack {
            Text(leftText)
                .foregroundColor(.secondary)
                .font(.callout)
            
            Spacer()
            
            Text(rightText)
                .font(.callout.bold())
        }
    }
}
