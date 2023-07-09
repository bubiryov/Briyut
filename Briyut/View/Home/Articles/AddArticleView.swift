//
//  AddArticleView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 23.06.2023.
//

import SwiftUI
import FirebaseFirestore
import PhotosUI

struct AddArticleView: View {
    
    @EnvironmentObject var articleViewModel: ArticlesViewModel
    @State private var tittle: String = ""
    @State private var textBody: String = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var isKeyboardVisible = false
    @State private var clippedProcedure: ProcedureModel? = nil
    @State private var showPhotosPicker: Bool = false
    @State private var showActionSheet: Bool = false
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var data: Data? = nil
    @State private var loading: Bool = false
        
    var body: some View {
        
        ZStack {
            
            Color.backgroundColor.edgesIgnoringSafeArea(.all)
            
            VStack {
                
                TopBar<BackButton, ClipButton>(
                    text: "new-article-string",
                    leftButton: BackButton(),
                    rightButton: ClipButton(
                        showActionSheet: $showActionSheet,
                        selectedPhoto: selectedPhoto,
                        data: data
                    )
                )
                
                ArticleInputField(
                    promptText: "title-string",
                    type: .tittle,
                    input: $tittle
                )
                .lineLimit(2)
                
                ArticleInputField(
                    promptText: "write-your-text-string",
                    type: .body,
                    input: $textBody
                )
                
                Spacer()
                
                if !isKeyboardVisible {
                    Button {
                        publishArticle()
                    } label: {
                        AccentButton(
                            text: "publish-string",
                            isButtonActive: validateFields(),
                            animation: loading
                        )
                    }
                    .disabled(!validateFields() || loading)
                }
            }
            .padding(.bottom, 10)
            .confirmationDialog("Choose an action", isPresented: $showActionSheet) {
                
                Button("choose-new-photo-string") {
                    showPhotosPicker = true
                }
                
                if selectedPhoto != nil {
                    Button(role: .destructive) {
                        selectedPhoto = nil
                    } label: {
                        Text("delete-current-photo-string")
                    }
                }
            }
            .photosPicker(
                isPresented: $showPhotosPicker,
                selection: $selectedPhoto,
                matching: .images,
                photoLibrary: .shared())
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
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                withAnimation {
                    isKeyboardVisible = true
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                withAnimation {
                    isKeyboardVisible = false
                }
            }
            .onChange(of: selectedPhoto) { _ in
                guard let item = selectedPhoto else { return }
                Task {
                    guard let data = try await item.loadTransferable(type: Data.self) else { return }
                    self.data = data
                }
            }
        .navigationBarBackButtonHidden()
        }
    }
}

struct AddArticleView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AddArticleView()
                .environmentObject(ArticlesViewModel())
        }
        .padding(.horizontal)
    }
}

fileprivate struct ArticleInputField: View {
    
    var promptText: String
    var title: String?
    var type: InputType
    @Binding var input: String
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title {
                Text(title)
                    .font(Mariupol.medium, 17)
            }
            
            TextField("", text: $input, prompt: Text(promptText.localized), axis: .vertical)
                .font(type == .tittle ? Font.custom(Mariupol.bold.rawValue, size: 22) : Font.custom(Mariupol.medium.rawValue, size: 17) )
                .padding()
                .frame(maxWidth: .infinity)
                .frame(minHeight: ScreenSize.height * 0.06)
                .frame(maxHeight: type == .tittle ? nil : .infinity, alignment: type == .tittle ? .center : .top)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(ScreenSize.width / 30)
        }
    }
    
    enum InputType {
        case tittle
        case body
    }
}

fileprivate struct ClipButton: View {
    
    @Binding var showActionSheet : Bool
    var selectedPhoto: PhotosPickerItem?
    var data: Data?
    
    var body: some View {
        Button {
            showActionSheet = true
        } label: {
            if selectedPhoto != nil {
                if let data = data, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: ScreenSize.height * 0.06, height: ScreenSize.height * 0.06, alignment: .center)
                        .clipped()
                        .cornerRadius(ScreenSize.width / 30)
                }
            } else {
                BarButtonView(image: "clip")
            }
        }
        .buttonStyle(.plain)
    }
}

extension AddArticleView {
    
    private func publishArticle() {
        Task {
            do {
                loading = true
                try await addNewArticle()
                presentationMode.wrappedValue.dismiss()
                loading = false
            } catch {
                print("Can't add new article")
                loading = false
            }
        }
    }
    
    private func addNewArticle() async throws {
        let articleId = UUID().uuidString
        var url: String? = nil
        
        if let selectedPhoto {
            let path = try await articleViewModel.savePhoto(item: selectedPhoto, articleId: articleId, childStorage: "articles")
            url = try await articleViewModel.getUrlForImage(path: path)
        }
        
        let article = ArticleModel(
            id: UUID().uuidString,
            title: tittle,
            body: textBody,
            dateCreated: Timestamp(date: Date()),
            pictureUrl: url
        )
        try await articleViewModel.createNewArticle(article: article)
    }

    private func validateFields() -> Bool {
        let isTitleEmpty = tittle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let isTextBodyEmpty = textBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        return !isTitleEmpty && !isTextBodyEmpty
    }

}
