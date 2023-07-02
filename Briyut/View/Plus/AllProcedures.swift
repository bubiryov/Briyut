//
//  AddProcedureView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 08.05.2023.
//

import SwiftUI

struct AllProcedures: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    @State private var isEditing: Bool = false
    @State private var searchText: String = ""
    @Binding var notEntered: Bool
    @Binding var showSearch: Bool
    @Binding var selectedTab: Tab
    @FocusState var focus: Bool
    private var procedures: [ProcedureModel] {
        var filteredProcedures: [ProcedureModel] = []
        if let user = vm.user, user.isDoctor {
            filteredProcedures = vm.procedures.filter({ $0.availableDoctors.contains(user.userId) })
        } else {
            filteredProcedures = vm.procedures
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
                    if vm.user?.isDoctor == true {
                        BarTitle<EditButton, AddProcedureButton>(
                            text: "procedures-string",
                            leftButton: EditButton(isEditing: $isEditing),
                            rightButton: AddProcedureButton(isEditing: $isEditing))
                    } else {
                        BarTitle<Text, SearchButton>(
                            text: "procedures-string",
                            rightButton: SearchButton(showSearch: $showSearch))
                    }
                                    
                    if alertContition() {
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
                    
                    if showSearch {
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
                    
                    ScrollView {
                        
                        ForEach(procedures, id: \.procedureId) { procedure in
                            
                            ProcedureRow(
                                vm: vm,
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
                            .disabled(vm.user?.isDoctor != true && alertContition() ? true : false)
                        }
                    }
                    .scrollIndicators(.hidden)
                }
                .onAppear {
                    Task {
                        try await vm.getAllProcedures()
                    }
                }
            }
        }
    }
    
    private func alertContition() -> Bool {
        guard vm.user?.name == nil || vm.user?.phoneNumber == nil, vm.user?.isDoctor == false else {
            return false
        }
        return true
    }
    
    private func randomize(interval: TimeInterval, withVariance variance: Double) -> TimeInterval {
        let random = (Double(arc4random_uniform(1000)) - 500.0) / 500.0
        return interval + variance * random
    }
    
}

struct AddProcedureView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AllProcedures(notEntered: .constant(false), showSearch: .constant(false), selectedTab: .constant(.plus))
                .environmentObject(ProfileViewModel())
        }
        .padding(.horizontal, 20)
        .background(Color.backgroundColor)
    }
}

struct AddProcedureButton: View {
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

struct ProcedureRow: View {
    
    var vm: ProfileViewModel
    var procedure: ProcedureModel
    var cornerRadius = ScreenSize.width / 30
    @Binding var isEditing: Bool
    @Binding var selectedTab: Tab
    
    var body: some View {
        
        NavigationLink {
            if isEditing {
                ProcedureView(
                    title: "editing-procedure-string",
                    buttonText: "save-changes-string",
                    procedure: procedure,
                    isEditing: $isEditing
                )
            } else {
                if vm.user?.isDoctor == true {
                    ChooseClientView(
                        procedure: procedure,
                        selectedTab: $selectedTab
                    )
                } else {
                    ChooseDoctorView(
                        procedure: procedure,
                        selectedTab: $selectedTab
                    )
                }
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(procedure.name)
                        .font(Mariupol.medium, 20)
                    Text("\(procedure.duration) \("min-string".localized)")
                        .font(Mariupol.regular, 14)
                }
                .padding(.vertical, 7)
                
                Spacer()
                
                VStack {
                    Text("₴ \(procedure.cost)")
                        .font(Mariupol.regular, 22)
                }
            }
            .padding(.horizontal, 20)
            .frame(minHeight: ScreenSize.height * 0.09)
            .background(Color.secondaryColor)
            .cornerRadius(cornerRadius)
        }
        .buttonStyle(.plain)
    }
}

struct EditButton: View {
    
    @Binding var isEditing: Bool
    
    var body: some View {
        Button {
            Haptics.shared.play(.light)
            withAnimation(.easeInOut(duration: 0.15)) {
                isEditing.toggle()
            }
        } label: {
            BarButtonView(image: "pencil", textColor: isEditing ? .white : nil, backgroundColor: isEditing ? .mainColor : nil)
        }
        .buttonStyle(.plain)
    }
}

struct SearchButton: View {
    
    @Binding var showSearch: Bool
    
    var body: some View {
        Button {
            Haptics.shared.play(.light)
            withAnimation(.easeInOut(duration: 0.15)) {
                if showSearch {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        hideKeyboard()
                    }
                }
                showSearch.toggle()
            }
        } label: {
            BarButtonView(image: "search")
        }
        .buttonStyle(.plain)
    }
}
