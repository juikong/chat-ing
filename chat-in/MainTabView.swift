//
//  MainTabView.swift
//  chat-in
//
//  Created by Juiko Ong on 30/08/2024.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .tabItem {
                    Label("Chats",
                          systemImage: "bubble")
                }
                .tag(0)
            SettingView()
                .tabItem {
                    Label("Settings",
                          systemImage: "gearshape")
                }
                .tag(1)
        }
    }
}

#Preview {
    MainTabView()
}
