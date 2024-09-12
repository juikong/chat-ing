//
//  ContentItemGroupView.swift
//  chat-in
//
//  Created by Juiko Ong on 02/08/2024.
//

import SwiftUI

struct ContentItemGroupView: View {
    var header: Header
    @StateObject private var departmentStore = DepartmentStore()
    @State private var serverurl: String = ""
    @State private var usertoken: String = ""
    
    var body: some View {
        HStack {
            AsyncMiniUserView(imageUrl: URL(string: "https://\(serverurl)/photos/\(departmentStore.department.photo)")!)
            VStack {
                Text(departmentStore.department.departmentname)
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
        usertoken = UserDefaults.standard.string(forKey: "accessToken") ?? "0"
    }
    
    func fetchAPIData() {
        guard let url = URL(string: "https://\(serverurl)/departments/\(header.department ?? "0")") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
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
}

#Preview {
    ContentItemGroupView(header: Header(_id: "66b72d32ee112e3437d0485b", sender: "66b0657899743b9e91aaf545", recipient: "66b0657899743b9e91aaf545", department: "66b09f103f56608cdb059d57", user: "66ac4979a5f45a210438f991", content: "Let's Start", updatedAt: "2024-08-07T07:42:36.185+00:00", __v: 0))
}
