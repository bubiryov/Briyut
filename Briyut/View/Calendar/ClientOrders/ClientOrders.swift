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
            
            CustomSegmentedPicker(options: ["Upcoming", "Recent"], selectedIndex: $selectedIndex)
            
            if selectedIndex == 0 {
                OrderList(vm: vm, selectedIndex: selectedIndex, orderArray: vm.activeOrders)
            } else {
                OrderList(vm: vm, selectedIndex: selectedIndex, orderArray: vm.doneOrders)
            }
            
            Spacer()
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
        
        VStack(spacing: 15) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(order.procedureName)
                        .font(.title3.bold())
                        .lineLimit(1)
                    
                    Text(orderDate())
                        .font(.subheadline.bold())
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("₴ \(order.price)")
                    .font(.title2)
                
            }
            
            if !order.isDone {
                
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
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 7)
        .frame(height: order.isDone ? ScreenSize.height * 0.12 : ScreenSize.height * 0.18)
        .background(order.isDone ? Color.secondary.opacity(0.1) : Color.secondaryColor)
        .cornerRadius(ScreenSize.width / 30)
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
                        vm.activeOrders = []
                        vm.activeLastDocument = nil
                        try await vm.removeOrder(orderId: order.orderId)
                        try await vm.getAllOrders(isDone: false, countLimit: 6)
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

struct OrderList: View {
    
    let vm: ProfileViewModel
    var selectedIndex: Int
    var orderArray: [OrderModel]
    
    var body: some View {
        List {
            ForEach(orderArray, id: \.orderId) { order in
                
                OrderRow(vm: vm, order: order)
                    .listRowInsets(EdgeInsets())
                    .padding(.bottom, 7)
                
                if order == orderArray.last {
                    HStack {
                        
                    }
                    .frame(height: 1)
                    .onAppear {
                        Task {
                            try await vm.getAllOrders(isDone: selectedIndex == 0 ? false : true, countLimit: 6)
                        }
                    }
                }
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.inset)
        .scrollIndicators(.hidden)
        .refreshable {
            vm.activeOrders = []
            vm.doneOrders = []
            vm.activeLastDocument = nil
            vm.doneLastDocument = nil
            Task {
                try await vm.getAllOrders(isDone: false, countLimit: 6)
                try await vm.getAllOrders(isDone: true, countLimit: 6)
            }
        }
    }
}
