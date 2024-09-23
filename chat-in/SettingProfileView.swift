//
//  SettingDetailView.swift
//  chat-in
//
//  Created by Juiko Ong on 03/08/2024.
//

import SwiftUI

struct SettingProfileView: View {
    @StateObject private var userStore = UserStore()
    @State private var email = ""
    @State private var username = ""
    @State private var displayname = ""
    @State private var departmentname = ""
    @State private var division = ""
    @State private var location = ""
    @State private var showAlert = false
    @State private var serverurl: String = ""
    @State private var userid: String = ""
    @State private var usertoken: String = ""
    @State private var showImagePicker = false
    @State private var showChangePassword = false
    @State private var selectedImageData: Data?
    
    var body: some View {
            ScrollView {
                VStack {
                    Button(action: {
#if os(iOS)
                        showImagePicker = true
#endif
                    }) {
                        AsyncUserView(imageUrl: URL(string: "https://\(serverurl)/photos/\(userStore.user.photo)")!)
                    }
                    .padding(.top)
                    Text("Email")
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top)
                    TextField("Email", text: $email, prompt: Text("Email"))
                        .padding(.horizontal)
                        .cornerRadius(5.0)
                        .background(.tertiary)
                    Text("Username")
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top)
                    TextField("Username", text: $username, prompt: Text("Username"))
                        .padding(.horizontal)
                        .cornerRadius(5.0)
                        .padding(.bottom)
                        .background(.tertiary)
                    Text("Display Name")
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top)
                    TextField("Display Name", text: $displayname, prompt: Text("Display Name"))
                        .padding(.horizontal)
                        .cornerRadius(5.0)
                        .padding(.bottom)
                        .background(.tertiary)
                    Text("Department Name")
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top)
                    TextField("Department Name", text: $departmentname, prompt: Text("Department Name"))
                        .padding(.horizontal)
                        .cornerRadius(5.0)
                        .padding(.bottom)
                        .background(.tertiary)
                    Text("Division")
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top)
                    TextField("Division", text: $division, prompt: Text("Division"))
                        .padding(.horizontal)
                        .cornerRadius(5.0)
                        .padding(.bottom)
                        .background(.tertiary)
                    Text("Location")
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top)
                    TextField("Location", text: $location, prompt: Text("Location"))
                        .padding(.horizontal)
                        .cornerRadius(5.0)
                        .padding(.bottom)
                        .background(.tertiary)
                    Spacer()
                    Button(action: {
                        updateProfile()
                    }) {
                        Text("Update")
                    }
                    .padding()
                }
#if os(iOS)
                .navigationBarItems(trailing:
                    Button(
                        "Change password",
                        action: {
                            showChangePassword = true
                        }
                    )
                )
#else
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button(action: {
                            showChangePassword = true
                        }) {
                            Text("Change password")
                        }
                    }
                }
#endif
                .onAppear {
                    getServerUrl()
                    getUserId()
                    fetchAPIData()
                }
                .sheet(isPresented: $showChangePassword) {
                    SettingPasswordView()
                }
#if os(iOS)
                .sheet(isPresented: $showImagePicker, onDismiss: {
                    if let imageData = selectedImageData {
                        uploadImage(imageData: imageData)
                    }
                }) {
                    ImagePickerView(selectedImageData: $selectedImageData)
                }
#endif
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Update Completed"),
                    message: Text("Your profile has been updated successfully."),
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
    
    func fetchAPIData() {
        guard let url = URL(string: "https://\(serverurl)/users/user/\(userid)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(usertoken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    userStore.updateUser(from: apiResponse)
                    username = apiResponse.username
                    email = apiResponse.email
                    if (apiResponse.displayname != "") {
                        displayname = apiResponse.displayname!
                    }
                    if (apiResponse.departmentname != "") {
                        departmentname = apiResponse.departmentname!
                    }
                    if (apiResponse.division != "") {
                        division = apiResponse.division!
                    }
                    if (apiResponse.location != "") {
                        location = apiResponse.location!
                    }
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    private func updateProfile() {
        guard let url = URL(string: "https://\(serverurl)/users/\(userid)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(usertoken)", forHTTPHeaderField: "Authorization")

        let updatedUser = UpdateUser(email: email, displayname: displayname, departmentname: departmentname, division: division, location: location)
        
        do {
            request.httpBody = try JSONEncoder().encode(updatedUser)
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
                print("Failed to update user, server error.")
            }
        }.resume()
    }
    
    func uploadImage(imageData: Data) {
        let url = URL(string: "https://\(serverurl)/users/\(userid)/photo")!

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(usertoken)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                showAlert = true
                fetchAPIData()
            } else {
                print("Failed to upload image.")
            }
        }

        task.resume()
    }
}

#Preview {
    SettingProfileView()
}
