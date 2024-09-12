//
//  ContentItemView.swift
//  chat-in
//
//  Created by Juiko Ong on 02/08/2024.
//

import SwiftUI

struct ContentItemView: View {
    var header: Header
    var chatType: String
    var body: some View {
        if chatType == "Single" {
            ContentItemSingleView(header: header)
        } else {
            ContentItemGroupView(header: header)
        }
    }
}

#Preview {
    ContentItemView(header: Header(_id: "66b3256cb34fc72bae103250", sender: "66ac483a9f7041b43eb34f79", recipient: "66ac4979a5f45a210438f991", user: "66ac4979a5f45a210438f991", content: "See me", updatedAt: "2024-08-07T07:42:36.185+00:00", __v: 0), chatType: "Single")
}
