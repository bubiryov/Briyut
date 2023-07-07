//
//  AddProcedureView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 08.05.2023.
//

import SwiftUI

struct AllProcedures: View {
    
    @EnvironmentObject var interfaceData: InterfaceData
    @EnvironmentObject var mainViewModel: MainViewModel
    @State private var isEditing: Bool = false
    @State private var searchText: String = ""
    @Binding var notEntered: Bool
    @Binding var showSearch: Bool
    @Binding var selectedTab: Tab
    @FocusState var focus: Bool
    private var procedures: [ProcedureModel] {
        var filteredProcedures: [ProcedureModel] = []
        if let user = interfaceData.user, user.isDoctor {
            filteredProcedures = interfaceData.procedures.filter({ $0.availableDoctors.contains(user.userId) })
        } else {
            filteredProcedures = interfaceData.procedures
        }
        
        let sortedProcedures = filteredProcedures.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        
        return sortedProcedures.filter { procedure in
            searchText.isEmpty ? true : procedure.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    
    var body: some View {
        NavigationView {
            ZStack {
                
                Color.backgroundColor.edgesIgnoringSafeArea(.all)
                
                VStack {
                    if interfaceData.user?.isDoctor == true {
                        TopBar<EditButton, AddProcedureButton>(
                            text: "procedures-string",
                            leftButton: EditButton(isEditing: $isEditing),
                            rightButton: AddProcedureButton(isEditing: $isEditing))
                    } else {
                        TopBar<Text, SearchButton>(
                            text: "procedures-string",
                            rightButton: SearchButton(showSearch: $showSearch))
                    }
                                    
                    if alertContition() {
                        personalInformationAlert
                    }
                    
                    if showSearch {
                        searchField
                    }
                    
                    ScrollView {
                        
                        ForEach(procedures, id: \.procedureId) { procedure in
                            
                            ProcedureRow(
                                interfaceData: interfaceData,
                                procedure: procedure,
                                isEditing: $isEditing,
                                selectedTab: $selectedTab
                            )
                            .offset(x: isEditing ? 2 : 0)
                            .offset(x: isEditing ? -2 : 0)
                            .animation(.easeInOut(duration: randomize(
                                interval: 0.12,
                                withVariance: 0.055
                            )).repeat(while: isEditing), value: isEditing)
                            .padding(.horizontal, isEditing ? 3 : 0)
                            .disabled(interfaceData.user?.isDoctor != true && alertContition() ? true : false)
                        }
                    }
                    .scrollIndicators(.hidden)
                }
                .onAppear {
                    Task {
                        try await mainViewModel.procedureViewModel.getAllProcedures()
                    }
                }
            }
        }
    }
}

struct AddProcedureView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AllProcedures(notEntered: .constant(false), showSearch: .constant(false), selectedTab: .constant(.plus))
                .environmentObject(InterfaceData())
                .environmentObject(MainViewModel(data: InterfaceData()))
        }
        .padding(.horizontal, 20)
        .background(Color.backgroundColor)
    }
}

fileprivate struct AddProcedureButton: View {
    
    @Binding var isEditing : Bool
    
    var body: some View {
        NavigationLink {
            ProcedureView(title: "new-procedure-string".localized, buttonText: "add-string".localized, isEditing: $isEditing)
        } label: {
            BarButtonView(image: "plus", scale: 0.35)
        }
        .buttonStyle(.plain)
    }
}

// MARK: Components

extension AllProcedures {
    
    var personalInformationAlert: some View {

        NavigationLink {
            EditProfileView(notEntered: $notEntered)
        } label: {
            HStack {
                HStack {
                    Text("all-procedures-message-string")
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .bold()
                        .multilineTextAlignment(.center)
                }
                .padding(5)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: ScreenSize.height * 0.06)
            .background(Color.mainColor)
            .cornerRadius(ScreenSize.width / 30)
        }
        .buttonStyle(.plain)

    }
    
    var searchField: some View {
        AccentInputField(
            promptText: "massage-string",
            title: nil,
            input: $searchText
        )
        .focused($focus)
        .onAppear {
            focus = true
        }
        .onDisappear {
            focus = false
            showSearch = false
            searchText = ""
        }
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.height < 30 {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            showSearch = false
                            searchText = ""
                            hideKeyboard()
                        }
                    }
                }
        )

    }
}

// MARK: Functions

extension AllProcedures {
    private func alertContition() -> Bool {
        guard interfaceData.user?.name == nil || interfaceData.user?.phoneNumber == nil, interfaceData.user?.isDoctor == false else {
            return false
        }
        return true
    }
    
    private func randomize(interval: TimeInterval, withVariance variance: Double) -> TimeInterval {
        let random = (Double(arc4random_uniform(1000)) - 500.0) / 500.0
        return interval + variance * random
    }

}
