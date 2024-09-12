//
//  ContentCreateItemView.swift
//  chat-in
//
//  Created by Juiko Ong on 12/08/2024.
//

import SwiftUI

struct ContentCreateItemView: View {
    var user: UserHeader
    @State private var serverurl: String = ""

    var body: some View {
        HStack {
            AsyncMiniUserView(imageUrl: URL(string: "https://\(serverurl)/photos/\(user.photo)")!)
            VStack {
                Text(user.displayname)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            getServerUrl()
        }
    }
    
    func getServerUrl() {
        serverurl = UserDefaults.standard.string(forKey: "serverurl") ?? ""
    }
}

#Preview {
    ContentCreateItemView(user: UserHeader(userId: "66bc2072615ba497c8bf690d", email: "richard@rookiess.shop", displayname: "richard_o", photo: "photo.png", headerId: "0"))
}
