//
//  AsyncLargeUserView.swift
//  chat-in
//
//  Created by Juiko Ong on 23/08/2024.
//

import SwiftUI

struct AsyncLargeUserView: View {
    let imageUrl: URL

    var body: some View {
        AsyncImage(url: imageUrl) { phase in
            switch phase {
            case .empty:
                Image(systemName: "person")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.gray)
                
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                
            case .failure(_):
                Image(systemName: "person")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.red)
                
            @unknown default:
                Image(systemName: "person")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.yellow)
            }
        }
    }
}
