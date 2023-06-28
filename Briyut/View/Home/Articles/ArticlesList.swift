//
//  ArticlesList.swift
//  Briyut
//
//  Created by Egor Bubiryov on 23.06.2023.
//

import SwiftUI
import CachedAsyncImage

struct ArticlesList: View {
    
    @EnvironmentObject var articleVM: ArticlesViewModel
    @EnvironmentObject var vm: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var loading: Bool = false
    
    var body: some View {

        VStack {
            BarTitle<BackButton, AddArticleButton>(
                text: "Interesting",
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
//        .onAppear {
//            Task {
//                do {
//                    loading = true
//                    try await articleVM.getRequiredArticles(countLimit: 6)
//                    loading = false
//                } catch {
//                    loading = false
//                }
//            }
//        }
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

struct ArticleRow: View {
    
    let article: ArticleModel
    @EnvironmentObject var articleVM: ArticlesViewModel
    @State private var showFullArticle: Bool = false
    
    var body: some View {
        HStack {
            if let url = article.pictureUrl {
                VStack {
                    CachedAsyncImage(url: URL(string: url), urlCache: .imageCache) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: ScreenSize.height * 0.1, height: ScreenSize.height * 0.1, alignment: .center)
                            .clipped()
                        
                    } placeholder: {
                        Text("Rubinko")
                            .lineLimit(1)
                            .padding(5)
                            .font(.custom("Alokary", size: 11))
                            .foregroundColor(.mainColor)
                            .tracking(1)
                            .frame(width: ScreenSize.height * 0.1, height: ScreenSize.height * 0.1)
                            .background(Color.white)
                            .cornerRadius(ScreenSize.width / 20)
                    }
                }
                .cornerRadius(ScreenSize.width / 20)
            } else {
                Text("Rubinko")
                    .lineLimit(1)
                    .padding(5)
                    .font(.custom("Alokary", size: 11))
                    .foregroundColor(.mainColor)
                    .tracking(1)
                    .frame(width: ScreenSize.height * 0.1, height: ScreenSize.height * 0.1)
                    .background(Color.white)
                    .cornerRadius(ScreenSize.width / 20)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text(article.title)
                    .font(Mariupol.medium, 20)
                    .lineLimit(1)
                
                Text(article.body)
                    .font(Mariupol.regular, 14)
                    .lineLimit(4)
                    .foregroundColor(.secondary)
            }
            .padding(.leading, 10)
            .frame(height: ScreenSize.height * 0.1, alignment: .top)

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 7)
        .frame(height: ScreenSize.height * 0.135)
        .background(Color.secondaryColor)
        .cornerRadius(ScreenSize.width / 20)
        .onTapGesture {
            Haptics.shared.play(.light)
            showFullArticle = true
        }
        .fullScreenCover(isPresented: $showFullArticle) {
            ArticleView(article: article)
        }
    }
}

struct AddArticleButton: View {
    
    @EnvironmentObject var articleVM: ArticlesViewModel

    var body: some View {
        NavigationLink {
            AddArticleView().environmentObject(articleVM)
        } label: {
            BarButtonView(image: "plus", scale: 0.35)
        }
        .buttonStyle(.plain)
    }
}

