//
//  ChooseClientView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 03.06.2023.
//

import SwiftUI

struct ChooseClientView: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    var procedure: ProcedureModel
    @State private var showSearch: Bool = false
    @State private var searchText: String = ""
    @Binding var selectedTab: Tab
    @FocusState var focus: Bool
        
    var filteredUsers: [DBUser] {
        return vm.users
            .filter {!($0.isBlocked ?? false)}
            .filter { user in
                searchText.isEmpty ? true : ((user.name ?? "") + " " + (user.lastName ?? "")).localizedCaseInsensitiveContains(searchText)
            }
    }
    
    var body: some View {

        ZStack {
            
            Color.backgroundColor.edgesIgnoringSafeArea(.all)

            VStack {
                BarTitle<BackButton, SearchButton>(
                    text: "choose-client-string",
                    leftButton: BackButton(),
                    rightButton: SearchButton(showSearch: $showSearch)
                )
                
                if showSearch {
                    AccentInputField(promptText: "user-name-string", title: nil, input: $searchText)
                        .disableAutocorrection(true)
                        .overlay(content: {
                            HStack {
                                Spacer()
                                Button {
                                    Haptics.shared.play(.light)
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        searchText = ""
                                        showSearch = false
                                        hideKeyboard()
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle")
                                }
                            }
                            .padding(.horizontal)
                            .foregroundColor(.secondary)
                            .buttonStyle(.plain)
                        })
                        .focused($focus)
                        .onAppear {
                            focus = true
                        }
                        .onDisappear {
                            focus = false
                        }
                        .gesture(
                            DragGesture()
                                .onEnded { gesture in
                                    if gesture.translation.height < 30 {
                                        withAnimation(.easeInOut(duration: 0.15)) {
                                            showSearch = false
                                            hideKeyboard()
                                        }
                                    }
                                }
                        )
                }
                
                ScrollView {
                    ForEach(filteredUsers, id: \.userId) { user in
                        NavigationLink {
                            DateTimeSelectionView(
                                doctor: vm.user,
                                procedure: procedure,
                                mainButtonTitle: "add-appointment-string",
                                client: user,
                                selectedTab: $selectedTab
                            )
                        } label: {
                            UserRow(
                                vm: vm,
                                user: user,
                                showButtons: false,
                                userStatus: .client
                            )
                        }
                        .disabled(showSearch)
                        .opacity(showSearch ? 0.4 : 1)
                    }
                }
                .scrollIndicators(.hidden)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        showSearch = false
                        hideKeyboard()
                    }
                }
                
            }
            .navigationBarBackButtonHidden(true)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        if gesture.translation.width > 100 {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
            )
        }
    }
}

struct ChooseClientView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ChooseClientView(procedure: ProcedureModel(procedureId: "", name: "", duration: 0, cost: 0, parallelQuantity: 1, availableDoctors: []), selectedTab: .constant(.home))
                .environmentObject(ProfileViewModel())
        }
        .padding(.horizontal, 20)
        .background(Color.backgroundColor)
    }
}
