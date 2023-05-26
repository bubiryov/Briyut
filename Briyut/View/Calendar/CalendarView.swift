//
//  CalendarView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 08.05.2023.
//

import SwiftUI

struct CalendarView: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    @Binding var doneAnimation: Bool
    @Binding var selectedTab: Tab
    
    var body: some View {
        if vm.user?.isDoctor == true {
            DoctorOrders()
        } else {
            ClientOrders(doneAnimation: $doneAnimation, selectedTab: $selectedTab)
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(doneAnimation: .constant(false), selectedTab: .constant(.calendar))
            .environmentObject(ProfileViewModel())
    }
}
