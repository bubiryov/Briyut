//
//  ProfileImage.swift
//  Briyut
//
//  Created by Egor Bubiryov on 03.07.2023.
//

import SwiftUI
import CachedAsyncImage

struct ProfileImage: View {
    
    var photoURL: String?
    var frame: CGFloat
    var color: Color
    var padding: CGFloat
    
    var body: some View {
        VStack {
            CachedAsyncImage(url: URL(string: photoURL ?? ""), urlCache: .imageCache) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: frame, height: frame, alignment: .center)
                    .clipped()
                
            } placeholder: {
                Image(systemName: "person.fill")
                    .resizable()
                    .padding(padding)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: frame, height: frame, alignment: .center)
                    .clipped()
                    .foregroundColor(.secondary)
                    .background(color)
            }
        }
    }
}

struct ProfileImage_Previews: PreviewProvider {
    static var previews: some View {
        ProfileImage(photoURL: "", frame: 150, color: .white, padding: 0)
    }
}
