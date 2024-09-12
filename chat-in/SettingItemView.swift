//
//  SettingItemView.swift
//  chat-in
//
//  Created by Juiko Ong on 03/08/2024.
//

import SwiftUI

struct SettingItemView: View {
    var title: String
    var body: some View {
        Text(title)
    }
}

#Preview {
    SettingItemView(title: "Profile")
}
