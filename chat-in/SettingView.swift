//
//  SettingView.swift
//  chat-in
//
//  Created by Juiko Ong on 02/08/2024.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedSetting: String? = nil
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedSetting) {
                NavigationLink(value: "Profile") {
                    SettingItemView(title: "Profile")
                }
            }
            .navigationTitle("Settings")
#if os(iOS)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        authViewModel.logOut()
                    }) {
                        Text("Log Out")
                    }
                }
            }
#else
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        authViewModel.logOut()
                    }) {
                        Text("Log Out")
                    }
                }
            }
#endif
        } detail: {
            if let selectedSetting = selectedSetting, selectedSetting == "Profile" {
                SettingProfileView()
            } else {
                Text("Select a setting")
            }
        }
        .navigationDestination(for: String.self) { value in
            if value == "Profile" {
                SettingProfileView()
            }
        }
    }
}

#Preview {
    SettingView()
}
