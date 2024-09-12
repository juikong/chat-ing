//
//  ContentItemSingleView.swift
//  chat-in
//
//  Created by Juiko Ong on 02/08/2024.
//

import SwiftUI

struct ContentItemSingleView: View {
    var header: Header
    @StateObject private var userStore = UserStore()
    @State private var serverurl: String = ""
    @State private var userid: String = ""
    @State private var usertoken: String = ""
    @State private var displayName: String = ""
    
    var body: some View {
        HStack {
            AsyncMiniUserView(imageUrl: URL(string: "https://\(serverurl)/photos/\(userStore.user.photo)")!)
            VStack {
                Text(displayName)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(header.content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            getServerUrl()
            getUserId()
            fetchAPIData()
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
        let chatGroup = header.recipient == userid ? header.sender : header.recipient
        guard let url = URL(string: "https://\(serverurl)/users/user/\(chatGroup)") else { return }

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
                    if (apiResponse.displayname == "") {
                        displayName = apiResponse.username
                    } else {
                        displayName = apiResponse.displayname!
                    }
                    userStore.updateUser(from: apiResponse)
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
}

#Preview {
    ContentItemSingleView(header: Header(_id: "66b3256cb34fc72bae103250", sender: "66ac483a9f7041b43eb34f79", recipient: "66ac4979a5f45a210438f991", user: "66ac4979a5f45a210438f991", content: "See me", updatedAt: "2024-08-07T07:42:36.185+00:00", __v: 0))
}
