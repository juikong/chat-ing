//
//  LoginView.swift
//  chat-in
//
//  Created by Juiko Ong on 25/08/2024.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var serverurl: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var serverlogin: String = ""
    @State private var path: [String] = []
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        VStack {
            Text("Chat-ing").font(.system(size: 50))
            TextField("Server URL", text: $serverurl)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                login()
            }) {
                Text("Sign In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .onAppear {
            serverlogin = UserDefaults.standard.string(forKey: "serverurl") ?? ""
            if (serverlogin != "" && authViewModel.isAutologin) {
                autologin()
            }
        }
    }
    
    private func login() {
        UserDefaults.standard.set(serverurl, forKey: "serverurl")
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(password, forKey: "password")
        guard let url = URL(string: "https://\(serverurl)/auth/login") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let loginData = [
            "username": username,
            "password": password
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: loginData, options: [])
        } catch {
            print("Failed to serialize login data: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.showError = true
                    self.errorMessage = "Network error: \(error?.localizedDescription ?? "Unknown error")"
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let accessToken = json["access_token"] as? String,
                   let userId = json["user_id"] as? String {
                    UserDefaults.standard.set(accessToken, forKey: "accessToken")
                    UserDefaults.standard.set(userId, forKey: "UserId")

                    DispatchQueue.main.async {
                        print("accessToken: \(accessToken)")
                        print("userId: \(userId)")
                        authViewModel.logIn()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showError = true
                        self.errorMessage = "Invalid response from server."
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.showError = true
                    self.errorMessage = "Failed to parse response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    private func autologin() {
        serverurl = UserDefaults.standard.string(forKey: "serverurl") ?? ""
        username = UserDefaults.standard.string(forKey: "username") ?? ""
        password = UserDefaults.standard.string(forKey: "password") ?? ""
        guard let url = URL(string: "https://\(serverurl)/auth/login") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let loginData = [
            "username": username,
            "password": password
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: loginData, options: [])
        } catch {
            print("Failed to serialize login data: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.showError = true
                    self.errorMessage = "Network error: \(error?.localizedDescription ?? "Unknown error")"
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let accessToken = json["access_token"] as? String,
                   let userId = json["user_id"] as? String {
                    UserDefaults.standard.set(accessToken, forKey: "accessToken")
                    UserDefaults.standard.set(userId, forKey: "UserId")

                    DispatchQueue.main.async {
                        authViewModel.logIn()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showError = true
                        self.errorMessage = "Invalid response from server."
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.showError = true
                    self.errorMessage = "Failed to parse response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

#Preview {
    LoginView()
}
