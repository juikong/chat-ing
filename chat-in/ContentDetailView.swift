//
//  ContentDetailView.swift
//  chat-in
//
//  Created by Juiko Ong on 02/08/2024.
//

import SwiftUI

struct ContentDetailView: View {
    var chatGroup: String
    var chatHeader: String
    var chatType: String
    var lastChat: String
    var body: some View {
        if chatType == "Single" {
            ContentDetailSingleView(chatGroup: chatGroup, chatHeader: chatHeader, lastChat: lastChat)
        } else {
            ContentDetailGroupView(chatGroup: chatGroup, chatHeader: chatHeader, lastChat: lastChat)
        }
    }
}

#Preview {
    ContentDetailView(chatGroup: "66ac483a9f7041b43eb34f79", chatHeader: "66b3256cb34fc72bae103250", chatType: "Single", lastChat: "Recipient")
}
