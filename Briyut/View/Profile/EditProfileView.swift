//
//  EditProfileView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 09.05.2023.
//

import SwiftUI
import PhotosUI
import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

struct EditProfileView: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String = ""
    @State private var lastName: String = ""
    @State private var phoneNumber: String = "+38"
    @State private var showAlert: Bool = false
    @Binding var notEntered: Bool
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var data: Data? = nil
    @State private var showActionSheet: Bool = false
    @State private var showPhotosPicker: Bool = false
    @State private var customSchedule: Bool = false
    @State private var workStartTime: Date = Date()
    @State private var workEndTime: Date = Date()
    @State private var vacation: Bool = false
    @State private var startVacation: Date = Date()
    @State private var endVacation: Date = Date()
    @State private var loading: Bool = false
    
    var body: some View {
        
        GeometryReader { _ in
            ZStack {
                
                Color.backgroundColor.edgesIgnoringSafeArea(.all)
                
                VStack {
                    BarTitle<BackButton, DeleteButton>(
                        text: "profile-editing-string",
                        leftButton: BackButton(),
                        rightButton: DeleteButton(showAlert: $showAlert)
                    )
                    .padding(.bottom)
                    
                    VStack {
                        ScrollView {
                            
                            Button {
                                showActionSheet = true
                            } label: {
                                VStack {
                                    if selectedPhoto == nil {
                                        ProfileImage(
                                            photoURL: vm.user?.photoUrl,
                                            frame: ScreenSize.height * 0.12,
                                            color: Color.secondary.opacity(0.1),
                                            padding: 16
                                        )
                                    } else {
                                        if let data = data, let image = UIImage(data: data) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: ScreenSize.height * 0.12, height: ScreenSize.height * 0.12, alignment: .center)
                                                .clipped()
                                        }
                                    }
                                }
                            }
                            .frame(height: ScreenSize.height * 0.12)
                            .cornerRadius(ScreenSize.width / 20)
                            .onChange(of: selectedPhoto) { _ in
                                guard let item = selectedPhoto else { return }
                                Task {
                                    guard let data = try await item.loadTransferable(type: Data.self) else { return }
                                    self.data = data
                                }
                            }
                            
                            VStack(spacing: ScreenSize.height * 0.02) {
                                AccentInputField(
                                    promptText: "Maria",
                                    title: "name-string",
                                    spaceAllow: false,
                                    input: $name
                                )
                                
                                AccentInputField(
                                    promptText: "Shevchenko",
                                    title: "last-name-string",
                                    spaceAllow: false,
                                    input: $lastName
                                )
                                
                                if !vm.authProviders.contains(.phone) {
                                    AccentInputField(promptText: "+38 (099)-999-99-99", title: "phone-number-string", input: $phoneNumber)
                                        .keyboardType(.phonePad)
                                }
                            }
                            if vm.user?.isDoctor ?? false {
                                VStack(spacing: 20) {
                                    
                                    Toggle(isOn: $customSchedule.animation()) {
                                        Text("custom-schedule-string")
                                            .font(Mariupol.medium, 17)
                                    }
                                    .tint(.mainColor)
                                    .padding(.trailing, 5)
                                    
                                    if customSchedule {
                                        DatePicker(selection: $workStartTime, displayedComponents: [.hourAndMinute]) {
                                            Text("start-string")
                                                .font(Mariupol.regular, 17)
                                        }
                                        .datePickerStyle(CompactDatePickerStyle())
                                        .environment(\.locale, Locale(identifier: "en_GB"))
                                        .tint(.mainColor)
                                        .onChange(of: workStartTime) { newTime in
                                            workStartTime = roundDateToNearestInterval(date: newTime)
                                        }
                                        
                                        DatePicker(selection: $workEndTime, displayedComponents: [.hourAndMinute]) {
                                            Text("end-string")
                                                .font(Mariupol.regular, 17)
                                        }
                                        .datePickerStyle(CompactDatePickerStyle())
                                        .environment(\.locale, Locale(identifier: "en_GB"))
                                        .tint(.mainColor)
                                        .onChange(of: workEndTime) { newTime in
                                            workEndTime = roundDateToNearestInterval(date: newTime)
                                        }
                                        
                                    }
                                }
                                .padding(.top)
                                
                                VStack(spacing: 20) {
                                    
                                    Toggle(isOn: $vacation.animation()) {
                                        Text("vacation-string")
                                            .font(Mariupol.medium, 17)
                                    }
                                    .tint(.mainColor)
                                    .padding(.trailing, 5)
                                    
                                    if vacation {
                                        DatePicker(
                                            selection: $startVacation,
                                            in: Date()...,
                                            displayedComponents: [.date]
                                        ) {
                                            Text("start-string")
                                                .font(Mariupol.regular, 17)
                                        }
                                        .datePickerStyle(CompactDatePickerStyle())
                                        .environment(\.locale, Locale(identifier: "en_GB"))
                                        .tint(.mainColor)
                                        
                                        DatePicker(
                                            selection: $endVacation,
                                            in: startVacation == Date() ? Date()... : startVacation...,
                                            displayedComponents: [.date]
                                        ) {
                                            Text("end-string")
                                                .font(Mariupol.regular, 17)
                                        }
                                        .datePickerStyle(CompactDatePickerStyle())
                                        .environment(\.locale, Locale(identifier: "en_GB"))
                                        .tint(.mainColor)
                                    }
                                }
                                .padding(.vertical)
                            }
                        }
                        .scrollIndicators(.hidden)
                        
                        Button {
                            Haptics.shared.play(.light)
                            Task {
                                loading = true
                                do {
                                    try await saveProfileAction()
                                    loading = false
                                } catch {
                                    print("Can't save changes")
                                    loading = false
                                }
                            }
                        } label: {
                            AccentButton(
                                text: "save-string",
                                isButtonActive: true,
                                animation: loading
                            )
                        }
                        .disabled(loading)
                    }
                    .ignoresSafeArea(.keyboard)
                    .confirmationDialog("Choose action", isPresented: $showActionSheet) {
                        Button("choose-new-photo-string") {
                            showPhotosPicker = true
                        }
                        
                        if let url = vm.user?.photoUrl, url != "" {
                            Button("delete-current-photo-string", role: .destructive) {
                                guard let user = vm.user else { return }
                                Task {
                                    try await vm.deletePreviousPhoto(url: url)
                                    try await vm.editProfile(
                                        userID: user.userId,
                                        name: name != "" ? name : nil,
                                        lastName: lastName != "" ? lastName : nil,
                                        phoneNumber: phoneNumber.count > 5 ? phoneNumber : nil,
                                        photoURL: nil,
                                        customSchedule: customSchedule,
                                        scheduleTimes: customSchedule ? [
                                            DateFormatter.customFormatter(format: "HH:mm").string(from: workStartTime) :
                                                DateFormatter.customFormatter(format: "HH:mm").string(from: workEndTime)
                                        ] : nil,
                                        vacation: vacation,
                                        vacationDates: vacation ? [
                                            Timestamp(date: startVacation),
                                                Timestamp(date: endVacation)
                                        ] : nil
                                    )
                                    try await vm.loadCurrentUser()
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
                    .photosPicker(
                        isPresented: $showPhotosPicker,
                        selection: $selectedPhoto,
                        matching: .images,
                        photoLibrary: .shared())
                }
                .padding(.bottom, 20)
                .navigationBarBackButtonHidden(true)
                .onAppear {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm"
                    
                    if let user = vm.user {
                        name = user.name ?? ""
                        lastName = user.lastName ?? ""
                        phoneNumber = user.phoneNumber ?? ""
                        customSchedule = user.customSchedule ?? false
                        workStartTime = dateFormatter.date(from: user.scheduleTimes?.keys.first ?? "08:00") ?? Date()
                        workEndTime = dateFormatter.date(from: user.scheduleTimes?.values.first ?? "21:00") ?? Date()
                        vacation = user.vacation ?? false
                        startVacation = user.vacationDates?[0].dateValue() ?? Date()
                        endVacation = user.vacationDates?[1].dateValue() ?? Date()
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("delete-account-alert-title-string"),
                        message: Text("delete-account-alert-message-string"),
                        primaryButton: .destructive(Text("yes-i'm-sure-string"), action: {
                            Task {
                                do {
                                    try await vm.deleteAccount()
                                    notEntered = true
                                } catch {
                                    print("Something went wrong")
                                }
                            }
                        }),
                        secondaryButton: .default(Text("cancel-string"), action: { })
                    )
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onEnded { gesture in
                            if gesture.translation.width > 100 {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                        .onEnded { gesture in
                            if gesture.translation.height > 100 {
                                hideKeyboard()
                            }
                        }
                )
            }
        }
        .ignoresSafeArea(.keyboard)
    }
    
    private func saveProfileAction() async throws {
        guard let user = vm.user else { return }
        var url: String = user.photoUrl ?? ""
        if let selectedPhoto {
            try await vm.deleteStorageFolderContents(documentId: user.userId, childStorage: "users")
            let path = try await vm.savePhoto(item: selectedPhoto, childStorage: "users")
            url = try await vm.getUrlForImage(path: path)
        }
        let scheduleTimes: [String : String]? = {
            if customSchedule {
                return [
                    DateFormatter.customFormatter(format: "HH:mm").string(from: workStartTime) :
                        DateFormatter.customFormatter(format: "HH:mm").string(from: workEndTime)
                ]
            } else {
                return nil
            }
        }()
        
        let vacationDates: [Timestamp]? = {
            if vacation {
                return [Timestamp(date: startVacation), Timestamp(date: endVacation)]
            } else {
                return nil
            }
        }()
        
        try await vm.editProfile(
            userID: user.userId,
            name: name != "" ? name : nil,
            lastName: lastName != "" ? lastName : nil,
            phoneNumber: phoneNumber.count > 5 ? phoneNumber : nil,
            photoURL: url,
            customSchedule: customSchedule,
            scheduleTimes: scheduleTimes,
            vacation: vacation,
            vacationDates: vacationDates
        )
        try await vm.loadCurrentUser()
        presentationMode.wrappedValue.dismiss()
    }
    
    private func roundDateToNearestInterval(date: Date) -> Date {
        let interval: TimeInterval = 15 * 60
        let timeInterval = date.timeIntervalSinceReferenceDate
        let roundedInterval = (timeInterval / interval).rounded() * interval

        let roundedDate = Date(timeIntervalSinceReferenceDate: roundedInterval)

        if roundedDate > Date() {
            return roundedDate.addingTimeInterval(-interval)
        }

        return roundedDate
    }

}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            EditProfileView(notEntered: .constant(false))
                .environmentObject(ProfileViewModel())
        }
        .padding(.horizontal, 20)
        .background(Color.backgroundColor)
    }
}

struct DeleteButton: View {
    
    @Binding var showAlert: Bool
    
    var body: some View {
        Button {
            showAlert = true
            Haptics.shared.notify(.warning)
        } label: {
            BarButtonView(image: "trash", textColor: .white, backgroundColor: Color.destructiveColor)
        }
        .buttonStyle(.plain)
    }
}
