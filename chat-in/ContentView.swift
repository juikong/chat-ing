//
//  ContentView.swift
//  chat-in
//
//  Created by Juiko Ong on 02/08/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var headerStore = HeaderStore()
    @State private var serverurl: String = ""
    @State private var userid: String = ""
    @State private var usertoken: String = ""
    @State private var timer: Timer?

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(headerStore.headers, id: \._id) { header in
                    NavigationLink {
                        if (header.department != nil) {
                            ContentDetailView(chatGroup: header.department!, chatHeader: header._id, chatType: "Group", lastChat: "Sender")
                        } else {
                            if (header.recipient == userid) {
                                ContentDetailView(chatGroup: header.sender, chatHeader: header._id, chatType: "Single", lastChat: "Recipient")
                            } else {
                                ContentDetailView(chatGroup: header.recipient, chatHeader: header._id, chatType: "Single", lastChat: "Sender")
                            }
                        }
                    } label: {
                        if (header.department != nil) {
                            ContentItemView(header: header, chatType: "Group")
                        } else {
                            ContentItemView(header: header, chatType: "Single")
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ContentCreateView(headers: headerStore.headers)) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
#else
                ToolbarItem(placement: .automatic) {
                    NavigationLink(destination: ContentCreateView(headers: headerStore.headers)) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
#endif
            }
            .onAppear {
                getServerUrl()
                getUserId()
                fetchAPIData()
                continueFetchAPIData()
            }
            .onDisappear {
                stopFetchAPIData()
            }
            .navigationTitle("Chat-ing")
        } detail: {
            Text("Select an item")
        }
    }

    private func deleteItems(at indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let itemToDelete = headerStore.headers[index]
        
        deleteHeaderFromAPI(itemID: itemToDelete._id) { success in
            if success {
                deleteMessagesFromAPI(itemID: itemToDelete._id) { success in
                    DispatchQueue.main.async {
                        headerStore.headers.remove(atOffsets: indexSet)
                    }
                }
            }
        }
    }
    
    func deleteHeaderFromAPI(itemID: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://\(serverurl)/headers/\(itemID)") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(usertoken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error deleting item: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            // Assuming the API responds with a success status code
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }.resume()
    }

    func deleteMessagesFromAPI(itemID: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://\(serverurl)/messages/header/\(itemID)") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(usertoken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error deleting item: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            // Assuming the API responds with a success status code
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }.resume()
    }
    
    func getServerUrl() {
        serverurl = UserDefaults.standard.string(forKey: "serverurl") ?? ""
    }
    
    func getUserId() {
        userid = UserDefaults.standard.string(forKey: "UserId") ?? "0"
        usertoken = UserDefaults.standard.string(forKey: "accessToken") ?? "0"
    }
    
    func fetchAPIData() {
        guard let url = URL(string: "https://\(serverurl)/headers/by-user?userId=\(userid)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(usertoken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    authViewModel.logOut()
                }
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode([Header].self, from: data)
                DispatchQueue.main.async {
                    headerStore.addHeaders(from: apiResponse)
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func continueFetchAPIData() {
        timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            fetchAPIData()
        }
    }
    
    func stopFetchAPIData() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    ContentView()
}
