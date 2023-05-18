//
//  OrderInformationView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 17.05.2023.
//

import SwiftUI

struct OrderInformationView: View {
    
    @Binding var showCard: Bool
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.0000001)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        showCard = false
                    }
                }
            
            VStack(spacing: 20) {
                
                ZStack {
                    
                    // Doctor photo
                    
                    HStack {
                        Spacer()
                        
                        ProfileImage(photoURL: "", frame: ScreenSize.height * 0.1, color: Color.white)
                            .cornerRadius(ScreenSize.width / 20)
                            .shadow(radius: 5, x: 7)

                    }
                    .frame(width: ScreenSize.height * 0.18)
                    
                    // User photo
                    
                    HStack {
                        ProfileImage(photoURL: "https://upload.wikimedia.org/wikipedia/commons/8/8c/Marcel_Hirscher_%28Portrait%29.jpg", frame: ScreenSize.height * 0.1, color: Color.white)
                            .cornerRadius(ScreenSize.width / 20)
                            .shadow(radius: 3, x: 10)
                        
                        Spacer()

                    }
                    .frame(width: ScreenSize.height * 0.18)
                }
                
                Text("Massage")
                    .font(.title2.bold())
                    .lineLimit(1)
                
                VStack(spacing: 20) {
                    
                    HStack {
                        Text("Patient")
                            .font(.callout)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("Emily Doe")
                            .font(.callout.bold())
                    }

                    
                    HStack {
                        Text("Specialist")
                            .font(.callout)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("Arkadiy Rubin")
                            .font(.callout.bold())
                    }
                    
                    HStack {
                        Text("Date")
                            .font(.callout)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("01.01.2026")
                            .font(.callout.bold())
                    }
                    
                    HStack {
                        Text("Time")
                            .font(.callout)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("13:30")
                            .font(.callout.bold())
                    }
                    
                    HStack {
                        Text("Total")
                            .font(.callout)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("₴ 800")
                            .font(.callout.bold())
                        
                    }
                }
                
//                Spacer()
                
                Button {
                    //
                } label: {
                    Text("Navigate")
                        .foregroundColor(.white)
                        .bold()
                }
                .buttonStyle(.plain)
                .frame(width: ScreenSize.width * 0.3, height: ScreenSize.height * 0.05)
                .background(Color.mainColor)
                .cornerRadius(ScreenSize.width / 30)

                
//                Spacer()
            }
            .padding(.horizontal, 40)
//            .padding(.vertical, 20)
            .frame(width: ScreenSize.width * 0.8, height: ScreenSize.height * 0.6)
            .background(Color.secondaryColor)
            .cornerRadius(ScreenSize.width / 20)
            .shadow(radius: 40, y: 5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)

//        .padding(.horizontal, 20)
    }
}

struct OrderInformationView_Previews: PreviewProvider {
    static var previews: some View {
        OrderInformationView(showCard: .constant(true))
    }
}
