//
//  AsyncMiniUserView.swift
//  chat-in
//
//  Created by Juiko Ong on 23/08/2024.
//

import SwiftUI

struct AsyncMiniUserView: View {
    let imageUrl: URL

    var body: some View {
        AsyncImage(url: imageUrl) { phase in
            switch phase {
            case .empty:
                Image(systemName: "person")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.gray)
                    .clipShape(Circle())
                    .padding()
                
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .padding()
                
            case .failure(_):
                Image(systemName: "person")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.red)
                    .clipShape(Circle())
                    .padding()
                
            @unknown default:
                Image(systemName: "person")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.yellow)
                    .clipShape(Circle())
                    .padding()
            }
        }
    }
}
