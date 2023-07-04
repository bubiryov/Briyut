//
//  ArticlesList.swift
//  Briyut
//
//  Created by Egor Bubiryov on 23.06.2023.
//

import SwiftUI

struct ArticlesList: View {
    
    @EnvironmentObject var articleVM: ArticlesViewModel
    @EnvironmentObject var vm: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var loading: Bool = false
    
    var body: some View {

        VStack {
            TopBar<BackButton, AddArticleButton>(
                text: "articles-string",
                leftButton: BackButton(),
                rightButton: vm.user?.isDoctor ?? false ? AddArticleButton() : nil
            )
            
            ScrollView {
                LazyVStack {
                    ForEach(articleVM.articles, id: \.id) { article in
                        
                        ArticleRow(article: article)
                        
                        if article == articleVM.articles.last {
                            HStack {

                            }
                            .frame(height: 1)
                            .onAppear {
                                getMoreArticles()
                            }
                            
                            if loading {
                                ProgressView()
                                    .tint(.mainColor)
                            }

                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.backgroundColor)
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.width > 100 {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        )
        .navigationBarBackButtonHidden()
    }
}

struct ArticlesList_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ArticlesList()
                .environmentObject(ProfileViewModel())
                .environmentObject(ArticlesViewModel())
        }
        .padding(.horizontal)
    }
}

extension ArticlesList {
    func getMoreArticles() {
        Task {
            do {
                loading = true
                try await articleVM.getRequiredArticles(countLimit: 6)
                loading = false
            } catch {
                loading = false
            }
        }
    }
}
