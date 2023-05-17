//
//  ClientOrders.swift
//  Briyut
//
//  Created by Egor Bubiryov on 15.05.2023.
//

import SwiftUI
import FirebaseFirestore

struct ClientOrders: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    @State private var selectedIndex = 0
    
    var body: some View {
        VStack {
            BarTitle<Text, Text>(text: "Appointments")
            
            CustomSegmentedPicker(options: ["Upcoming", "Recent"], selectedIndex: $selectedIndex, vm: vm)
                                    
            List {
                ForEach(vm.orders, id: \.orderId) { order in
                    OrderRow(vm: vm, order: order)
                        .listRowInsets(EdgeInsets())
                        .padding(.bottom, 7)
                    
                    if order == vm.orders.last {
                        ProgressView()
                            .onAppear {
                                Task {
                                    try await vm.getAllOrders(isDone: false, countLimit: 4)
                                }
                            }
                    }

                    
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.inset)
            .scrollIndicators(.hidden)
            
            Spacer()
        }
        .onDisappear {
            Task {
                if selectedIndex == 1 {
                    vm.orders = []
                    vm.lastDocument = nil
                    try await vm.getAllOrders(isDone: false, countLimit: 4)
                }
            }
        }
    }
}

struct ClientOrders_Previews: PreviewProvider {
    static var previews: some View {
        ClientOrders()
            .environmentObject(ProfileViewModel())
    }
}

struct CustomSegmentedPicker: View {

    let options: [String]
    @Binding var selectedIndex: Int
    @Namespace private var animation
    let vm: ProfileViewModel

    var body: some View {
        ZStack {
            HStack {
                RoundedRectangle(cornerRadius: ScreenSize.width / 30)
                    .frame(width: ScreenSize.width * 0.45)
                    .frame(height: ScreenSize.height * 0.06)
                    .foregroundColor(Color.mainColor)
            }
            .frame(maxWidth: .infinity, alignment: selectedIndex == 0 ? .leading : .trailing)
            
            HStack {
                ForEach(options.indices, id: \.self) { index in
                    Button {
                        Task {
                            if selectedIndex == 0 {
                                vm.orders = []
                                vm.lastDocument = nil
                                try await vm.getAllOrders(isDone: false, countLimit: 10)
                            } else {
                                vm.orders = []
                                vm.lastDocument = nil
                                try await vm.getAllOrders(isDone: true, countLimit: 10)
                            }
                        }
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedIndex = index
                        }
                    } label: {
                        Text(options[index])
                            .bold()
                            .foregroundColor(selectedIndex == index ? .white : .black)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .background(Color.secondaryColor)
        .frame(height: ScreenSize.height * 0.06)
        .cornerRadius(ScreenSize.width / 30)
    }
}

struct OrderRow: View {
    
    let vm: ProfileViewModel
    let order: OrderModel
    @State private var doctor: DBUser? = nil
    @State private var showAlert: Bool = false
    
    var body: some View {
        
        VStack {
            HStack(spacing: 10) {
                
                ProfileImage(photoURL: doctor?.photoUrl, frame: ScreenSize.height * 0.11, color: Color.white)
                    .cornerRadius(ScreenSize.width / 20)
                                
                VStack(alignment: .leading) {
                    
                    Text(order.procedureName)
                        .font(.title3.bold())
                        .lineLimit(1)
                                        
                    Spacer()
                    
                    Text(order.doctorName)
                        .font(.subheadline.bold())
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(orderDate())
                        .font(.subheadline.bold())
                    
                }
                .padding(.horizontal, 10)
                .frame(height: ScreenSize.height * 0.1)
            }
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: ScreenSize.height * 0.1)
                        
            if !order.isDone {
                
                Spacer()
                
                HStack {
                    Button {
                        Task {
                            showAlert = true
                        }
                    } label: {
                        Text("Cancel")
                            .foregroundColor(.black)
                            .bold()
                            .frame(width: ScreenSize.width * 0.4, height: ScreenSize.height * 0.05)
                            .background(Color.white)
                            .cornerRadius(ScreenSize.width / 30)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Button {
                        //
                    } label: {
                        Text("Reschedule")
                            .foregroundColor(.white)
                            .bold()
                            .frame(width: ScreenSize.width * 0.4, height: ScreenSize.height * 0.05)
                            .background(Color.mainColor)
                            .cornerRadius(ScreenSize.width / 30)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 15)
        .frame(height: order.isDone ? ScreenSize.height * 0.15 : ScreenSize.height * 0.22)
        .background(order.isDone ? Color.secondary.opacity(0.1) : Color.secondaryColor)
        .cornerRadius(ScreenSize.width / 30)
        .frame(maxWidth: .infinity)
        .onAppear {
            Task {
                doctor = try await vm.getUser(userId: order.doctorId)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Are you sure you want to remove the appointment?"),
                primaryButton: .destructive(Text("Remove"), action: {
                    Task {
                        try await vm.removeOrder(orderId: order.orderId)
                        vm.lastDocument = nil
                        vm.orders = []
                        try await vm.getAllOrders(isDone: false, countLimit: 10)
                    }
                }),
                secondaryButton: .default(Text("Cancel"), action: {
                    
                })
            )
        }

    }
    
    func orderDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy, HH:mm"
        return dateFormatter.string(from: order.date.dateValue())
    }
    
}
