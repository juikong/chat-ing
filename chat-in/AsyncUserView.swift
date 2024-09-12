//
//  AsyncUserView.swift
//  chat-in
//
//  Created by Juiko Ong on 23/08/2024.
//

import SwiftUI

struct AsyncUserView: View {
    let imageUrl: URL

    var body: some View {
        AsyncImage(url: imageUrl) { phase in
            switch phase {
            case .empty:
                Image(systemName: "person")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                
            case .failure(_):
                Image(systemName: "person")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.red)
                
            @unknown default:
                Image(systemName: "person")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.yellow)
            }
        }
    }
}
