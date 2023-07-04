//
//  CustomSegmentedPicker.swift
//  Briyut
//
//  Created by Egor Bubiryov on 03.07.2023.
//

import SwiftUI

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
                        Text(options[index].localized)
                            .font(Mariupol.medium, 17)
                            .foregroundColor(selectedIndex == index ? .white : .primary)
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

struct CustomSegmentedPicker_Previews: PreviewProvider {
    static var previews: some View {
        CustomSegmentedPicker(options: [], selectedIndex: .constant(0))
    }
}
