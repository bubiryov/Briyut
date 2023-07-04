//
//  AddArticleButton.swift
//  Briyut
//
//  Created by Egor Bubiryov on 03.07.2023.
//

import SwiftUI

struct AddArticleButton: View {
    
    @EnvironmentObject var articleVM: ArticlesViewModel

    var body: some View {
        NavigationLink {
            AddArticleView()
                .environmentObject(articleVM)
        } label: {
            BarButtonView(image: "plus", scale: 0.35)
        }
        .buttonStyle(.plain)
    }
}

struct AddArticleButton_Previews: PreviewProvider {
    static var previews: some View {
        AddArticleButton()
            .environmentObject(ArticlesViewModel())
    }
}
