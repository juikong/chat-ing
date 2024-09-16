//
//  SettingPasswordView.swift
//  chat-in
//
//  Created by Juiko Ong on 03/08/2024.
//

import SwiftUI

struct SettingPasswordView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var password = ""
    @State private var confirmpassword = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var serverurl: String = ""
    @State private var userid: String = ""
    @State private var usertoken: String = ""
    
    var body: some View {
        VStack {
            Text("Password")
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
            SecureField("NewPassword", text: $password, prompt: Text("New Password"))
                .padding(.horizontal)
                .cornerRadius(5.0)
                .background(.tertiary)
            Text("Confirm Password")
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
            SecureField("Confirm New Password", text: $confirmpassword, prompt: Text("Confirm New Password"))
                .padding(.horizontal)
                .cornerRadius(5.0)
                .padding(.bottom)
                .background(.tertiary)
            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            Spacer()
            Button(action: {
                changePassword()
            }) {
                Text("Update")
            }
            .padding()
            Button("Cancel") {
                dismiss()
            }
            .padding()
        }
        .onAppear {
            getServerUrl()
            getUserId()
        }
    }
    
    func getServerUrl() {
        serverurl = UserDefaults.standard.string(forKey: "serverurl") ?? ""
    }
    
    func getUserId() {
        userid = UserDefaults.standard.string(forKey: "UserId") ?? "0"
        usertoken = UserDefaults.standard.string(forKey: "accessToken") ?? "0"
    }
    
    private func changePassword() {
        if password != confirmpassword {
            //passwordAlert = true
            self.showError = true
            self.errorMessage = "Password and Confirm Password must match."
            return
        }
        
        guard let url = URL(string: "https://\(serverurl)/users/\(userid)/password") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(usertoken)", forHTTPHeaderField: "Authorization")

        let userPassword = UserPassword(password: password)
        
        do {
            request.httpBody = try JSONEncoder().encode(userPassword)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            print("Failed to encode user data: \(error.localizedDescription)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to update user: \(error.localizedDescription)")
                return
            }

            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                DispatchQueue.main.async {
                    authViewModel.logOut()
                }
            } else {
                self.showError = true
                self.errorMessage = "Failed to change password."
                print("Failed to update user, server error.")
            }
        }.resume()
    }
}

#Preview {
    SettingPasswordView()
}
