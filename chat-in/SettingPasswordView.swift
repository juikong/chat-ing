//
//  SettingPasswordView.swift
//  chat-in
//
//  Created by Juiko Ong on 03/08/2024.
//

import SwiftUI

struct SettingPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @State private var password = ""
    @State private var confirmpassword = ""
    @State private var showAlert = false
    @State private var passwordAlert = false
    @State private var errorAlert = false
    @State private var serverurl: String = ""
    @State private var userid: String = ""
    @State private var usertoken: String = ""
    
    var body: some View {
        VStack {
            Text("Password")
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
            TextField("NewPassword", text: $password, prompt: Text("New Password"))
                .padding(.horizontal)
                .cornerRadius(5.0)
                .background(.tertiary)
            Text("Confirm Password")
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
            TextField("Confirm New Password", text: $confirmpassword, prompt: Text("Confirm New Password"))
                .padding(.horizontal)
                .cornerRadius(5.0)
                .padding(.bottom)
                .background(.tertiary)
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
            getUserId()
        }
        .alert(isPresented: $passwordAlert) {
            Alert(
                title: Text("Change Password"),
                message: Text("Password and Confirm Password must match."),
                dismissButton: .default(Text("OK")) {
                    password = ""
                    confirmpassword = ""
                }
            )
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Change Password"),
                message: Text("Your password has been changed successfully."),
                dismissButton: .default(Text("OK")) {
                    password = ""
                    confirmpassword = ""
                }
            )
        }
        .alert(isPresented: $errorAlert) {
            Alert(
                title: Text("Change Password"),
                message: Text("Failed to change password."),
                dismissButton: .default(Text("OK")) {
                    //
                }
            )
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
            passwordAlert = true
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
                showAlert = true
            } else {
                errorAlert = true
                print("Failed to update user, server error.")
            }
        }.resume()
    }
}

#Preview {
    SettingPasswordView()
}
