//
//  CalendarView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 08.05.2023.
//

import SwiftUI

struct CalendarView: View {
    var body: some View {
        VStack {
            BarTitle<Text, Text>(text: "Calendar")
            Spacer()
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
