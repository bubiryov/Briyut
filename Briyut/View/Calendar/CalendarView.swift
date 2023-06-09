//
//  CalendarView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 08.05.2023.
//

import SwiftUI

struct CalendarView: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    
    var body: some View {
        if vm.user?.isDoctor == true {
            DoctorOrders()
        } else {
            ClientOrders()
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
            .environmentObject(ProfileViewModel())
    }
}
