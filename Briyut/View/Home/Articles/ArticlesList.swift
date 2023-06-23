//
//  ArticlesList.swift
//  Briyut
//
//  Created by Egor Bubiryov on 23.06.2023.
//

import SwiftUI

struct ArticlesList: View {
    var body: some View {
        NavigationView {
            VStack {
                BarTitle<BackButton, Text>(
                    text: "Interesting",
                    leftButton: BackButton()
                )
                ScrollView {
                    ArticleRow()
                }
            }
        }
    }
}

struct ArticlesList_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ArticlesList()
        }
        .padding(.horizontal)
    }
}

struct ArticleRow: View {
    var body: some View {
        HStack {
            Text("Rubinko")
                .lineLimit(1)
                .padding(5)
                .font(.custom("Alokary", size: 11))
                .foregroundColor(.mainColor)
                .tracking(1)
                .frame(width: ScreenSize.height * 0.1, height: ScreenSize.height * 0.1)
                .background(Color.white)
                .cornerRadius(ScreenSize.width / 20)
            
//            ProfileImage(
//                photoURL: "https://hips.hearstapps.com/hmg-prod/images/spa-woman-female-enjoying-massage-in-spa-centre-royalty-free-image-492676582-1549988720.jpg?crop=1.00xw:0.755xh;0,0&resize=1200:*",
//                frame: ScreenSize.height * 0.1,
//                color: .clear,
//                padding: 16
//            )
//                .cornerRadius(ScreenSize.width / 20)

            
            VStack(alignment: .leading, spacing: 10) {
                Text("Лікування болю в шиї")
                    .font(Mariupol.medium, 20)
                    .lineLimit(1)
                
                Text("Болі в шиї — частий стан, що зустрічається у 20% дорослого населення. За статистикою хворобливі прояви у шийному відділі частіше відчувають жінки. Симптоматика носить у пацієнтів різний характер — від ниючого, наростаючого поступово болю до гострого і навіть “стріляючого”. Багато пацієнтів, не усвідомлюючи серйозність проблеми, не поспішають по медичну допомогу. При тому біль не тільки суттєво знижує якість життя, а й може вказувати на серйозні патології, які можуть призвести до паралічу.")
                    .font(Mariupol.regular, 14)
                    .lineLimit(4)
                    .foregroundColor(.secondary)
                
            }
            .padding(.leading, 10)
//            .padding(.vertical, 10)
            .frame(height: ScreenSize.height * 0.1, alignment: .top)

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: ScreenSize.height * 0.135)
        .padding(.horizontal, 20)
        .padding(.vertical, 7)
        .background(Color.secondaryColor)
        .cornerRadius(ScreenSize.width / 20)
    }
}
