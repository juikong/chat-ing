//
//  SettingView.swift
//  chat-in
//
//  Created by Juiko Ong on 02/08/2024.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink {
                    SettingProfileView()
                } label: {
                    SettingItemView(title: "Profile")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        authViewModel.logOut()
                    }) {
                        Text("Log Out")
                    }
                }
            }
        }
    }
}

#Preview {
    SettingView()
}
