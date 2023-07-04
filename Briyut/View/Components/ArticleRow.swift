//
//  ArticleRow.swift
//  Briyut
//
//  Created by Egor Bubiryov on 03.07.2023.
//

import SwiftUI
import CachedAsyncImage
import FirebaseFirestore

struct ArticleRow: View {
    
    let article: ArticleModel
    @EnvironmentObject var articleVM: ArticlesViewModel
    @State private var showFullArticle: Bool = false
    
    var body: some View {
        HStack {
            if let url = article.pictureUrl {
                articleRowPicture(url: url)
            } else {
                articleRowPicturePlaceholder
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

struct ArticleRow_Previews: PreviewProvider {
    static var previews: some View {
        ArticleRow(article: ArticleModel(
            id: "",
            title: "Лікування болю в шиї",
            body: "Болі в шиї — частий стан, що зустрічається у 20% дорослого населення. За статистикою хворобливі прояви у шийному відділі частіше відчувають жінки",
            dateCreated: Timestamp(date: Date()),
            pictureUrl: nil)
        )
    }
}

extension ArticleRow {
    
    func articleRowPicture(url: String) -> some View {
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
    }
    
    var articleRowPicturePlaceholder: some View {
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
