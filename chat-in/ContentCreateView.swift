//
//  ContentCreateView.swift
//  chat-in
//
//  Created by Juiko Ong on 12/08/2024.
//

import SwiftUI

struct ContentCreateView: View {
    var headers: [Header]
    @StateObject private var userStore = UserStore()
    @State private var serverurl: String = ""
    @State private var userid: String = ""
    @State private var usertoken: String = ""
    
    var body: some View {
        List {
            ForEach(userStore.userHeaders, id: \.userId) { user in
                NavigationLink {
                    ContentCreateDetailView(userid: user.userId, displayname: user.displayname, photo: user.photo)
                } label: {
                    ContentCreateItemView(user: user)
                }
            }
        }
        .onAppear {
            getServerUrl()
            getUserId()
            fetchAPIData()
        }
        .navigationTitle("Add New Message")
    }
        
    func getServerUrl() {
        serverurl = UserDefaults.standard.string(forKey: "serverurl") ?? ""
    }
    
    func getUserId() {
        userid = UserDefaults.standard.string(forKey: "UserId") ?? "0"
        usertoken = UserDefaults.standard.string(forKey: "accessToken") ?? "0"
    }
    
    func fetchAPIData() {
        guard let url = URL(string: "https://\(serverurl)/users/allusers") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(usertoken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode([User].self, from: data)
                DispatchQueue.main.async {
                    userStore.getHeaders(from: apiResponse, userId: userid)
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
}

#Preview {
    ContentCreateView(headers: [Header(_id: "66b3256cb34fc72bae103250", sender: "66ac483a9f7041b43eb34f79", recipient: "66ac4979a5f45a210438f991", department: "0", user: "66ac4979a5f45a210438f991", content: "See me", updatedAt: "2024-08-07T07:42:36.185+00:00", __v: 0)])
}
