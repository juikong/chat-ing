//
//  ContentDetailGroupView.swift
//  chat-in
//
//  Created by Juiko Ong on 02/08/2024.
//

import SwiftUI

struct ContentDetailGroupView: View {
    var chatGroup: String
    var chatHeader: String
    var lastChat: String
    @StateObject private var messageStore = MessageStore()
    @StateObject private var departmentStore = DepartmentStore()
    @StateObject private var userStore = UserStore()
    @State private var isSending: Bool = false
    @State private var message = ""
    @State private var serverurl: String = ""
    @State private var userid: String = ""
    @State private var usertoken: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ScrollView {
                    ForEach(messageStore.messages, id: \._id) { message in
                        if (message.sender == userid) {
                            VStack {
                                Text(formatDate(from: message.createdAt))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                HStack {
                                    Text(message.content).font(.title3)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .padding()
                                    AsyncMiniUserView(imageUrl: URL(string: "https://\(serverurl)/photos/\(userStore.user.photo)")!)
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .background(.tertiary)
                            }
                        } else {
                            VStack {
                                Text(formatDate(from: message.createdAt))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                HStack {
                                    AsyncMiniUserView(imageUrl: URL(string: "https://\(serverurl)/photos/\(departmentStore.department.photo)")!)
                                    Text(message.content).font(.title3)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.tertiary)
                            }
                        }
                    }
                }
                .defaultScrollAnchor(.bottom)
                Spacer()
                HStack {
                    TextField("Messages", text: $message)
                        .padding(.vertical)
                        .padding(.leading)
                        .background(.white)
                    Button(action: {
                        sendMessage()
                    }) {
                        Image(systemName: "paperplane.circle.fill")
                    }
                    .padding(.trailing)
                    .disabled(isSending || message.isEmpty)
                }
                .frame(alignment: .bottom)
            }
            .onAppear {
                getServerUrl()
                getUserId()
                fetchAPIData()
                fetchAPIData2()
                fetchAPIData3()
            }
            .navigationTitle(departmentStore.department.departmentname)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func sendMessage() {
        //
    }
    
    func getServerUrl() {
        serverurl = UserDefaults.standard.string(forKey: "serverurl") ?? ""
    }
    
    func getUserId() {
        userid = UserDefaults.standard.string(forKey: "UserId") ?? "0"
        usertoken = UserDefaults.standard.string(forKey: "accessToken") ?? "0"
    }
    
    func fetchAPIData() {
        guard let url = URL(string: "https://\(serverurl)/messages/by-header?headerId=\(chatHeader)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(usertoken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode([Message].self, from: data)
                DispatchQueue.main.async {
                    messageStore.addMessages(from: apiResponse)
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func fetchAPIData2() {
        guard let url = URL(string: "https://\(serverurl)/departments/\(chatGroup)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(usertoken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(Department.self, from: data)
                DispatchQueue.main.async {
                    departmentStore.updateDepartment(from: apiResponse)
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func fetchAPIData3() {
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
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func formatDate(from dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        inputFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Ensure correct time zone

        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return outputFormatter.string(from: date)
        } else {
            return dateString // Return the original string if parsing fails
        }
    }
}

#Preview {
    ContentDetailGroupView(chatGroup: "66b09f103f56608cdb059d57", chatHeader: "66b72d32ee112e3437d0485b", lastChat: "Recipient")
}
