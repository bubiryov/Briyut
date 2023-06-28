//
//  ArticleView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 25.06.2023.
//

import SwiftUI
import FirebaseFirestore
import CachedAsyncImage

struct ArticleView: View {
    
    let article: ArticleModel
    @EnvironmentObject var articleVM: ArticlesViewModel
    @EnvironmentObject var vm: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert: Bool = false
    
    var body: some View {
        
        VStack {
            BarTitle<BackButton, DeleteButton>(
                text: "",
                leftButton: BackButton(),
                rightButton: vm.user?.isDoctor ?? false ? DeleteButton(showAlert: $showAlert) : nil
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text(article.title)
                            .font(Mariupol.bold, 30)
                        
                        Text(DateFormatter.customFormatter(format: "dd MMM yyyy, HH:mm").string(from: article.dateCreated.dateValue()))
                            .font(Mariupol.medium, 14)
                            .foregroundColor(.secondary)
                    }
                    
                    if let pictureUrl = article.pictureUrl, pictureUrl != "" {
                        CachedAsyncImage(url: URL(string: pictureUrl), urlCache: .imageCache) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: ScreenSize.height * 0.18)
                                .cornerRadius(ScreenSize.height / 50)
                                .clipped()
                            
                        } placeholder: {
                            HStack {
                                ProgressView()
                            }
                            .frame(height: ScreenSize.height * 0.18)
                            .frame(maxWidth: .infinity)
                            .background(Color.secondaryColor)
                            .cornerRadius(ScreenSize.height / 50)
                        }
                    }
                    
                    
                    Text(article.body)
                        .font(Mariupol.regular, 17)
                        .lineSpacing(10)
                    
                    HStack {
                        
                    }
                    .frame(height: 10)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.top, topPadding())
        .padding(.horizontal, 20)
        .background(Color.backgroundColor)
        .navigationBarBackButtonHidden()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Are you sure you want to delete the article?"),
                primaryButton: .destructive(Text("Delete"), action: {
                    Task {
                        do {
                            try await articleVM.removeArticle(article_id: article.id)
//                            articleVM.articles = []
//                            articleVM.lastArticle = nil
//                            try await articleVM.getRequiredArticles(countLimit: 6)
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            print("Something went wrong")
                        }
                    }
                }),
                secondaryButton: .default(Text("Cancel"), action: { })
            )
        }

    }
}

struct ArticleView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleView(article: ArticleModel(
            id: "",
            title: "Лікування болю в шиї",
            body: "Болі в шиї — частий стан, що зустрічається у 20% дорослого населення. За статистикою хворобливі прояви у шийному відділі частіше відчувають жінки. \n\nСимптоматика носить у пацієнтів різний характер — від ниючого, наростаючого поступово болю до гострого і навіть “стріляючого”. Багато пацієнтів, не усвідомлюючи серйозність проблеми, не поспішають по медичну допомогу. При тому біль не тільки суттєво знижує якість життя, а й може вказувати на серйозні патології, які можуть призвести до паралічу.\n Причини, через які з’являється біль у шиї, різноманітні та множинні. Серед частих — дегенеративні процеси, викликані артрозом чи спондилезом. Також стан може бути спричинений бактеріальним фактором, запаленнями, спазмом або травмою м’язів, защемленням нервового закінчення. Також при деяких захворюваннях іншого відділу хребта, бурситі, інших запаленнях у плечі в шию може віддавати біль, що спочатку виник в інших областях. Цей процес називається іррадіацією. Провокують біль у ділянці шиї різні травми, професійне заняття спортом, пов’язане з високими фізичними навантаженнями. Через велику кількість причин, які провокують болі шиї важливо провести точну диференційовану діагностику. Адже від того залежатимуть методи та тривалість лікування.",
            dateCreated: Timestamp(date: Date()),
            pictureUrl: "https://otdyhateli.cm/wp-content/uploads/2016/04/42.jpg"))
        .environmentObject(ProfileViewModel())
        .environmentObject(ArticlesViewModel())
    }
}
