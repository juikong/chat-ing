//
//  UserStore.swift
//  chat-in
//
//  Created by Juiko Ong on 12/08/2024.
//

import SwiftUI

@MainActor
class UserStore: ObservableObject {
    @Published var user: User = User(_id: "0", email: "john.doe@email.com", username: "john.doe", photo: "photo.png", __v: 0)
    @Published var users: [User] = []
    @Published var userHeaders: [UserHeader] = []

    func getHeaders(for otherId: String, userId: String, completion: @escaping (String) -> Void) {
        let serverurl = UserDefaults.standard.string(forKey: "serverurl") ?? ""
        
        guard let url = URL(string: "https://\(serverurl)/headers/new-user?userId=\(userId)&otherId=\(otherId)") else {
            completion("0")
            return
        }

        let usertoken = UserDefaults.standard.string(forKey: "accessToken") ?? "0"
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(usertoken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion("0")
                return
            }
            
            do {
                if let headers = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]],
                   let firstHeader = headers.first,
                   let headerId = firstHeader["_id"] as? String {
                    completion(headerId)
                } else {
                    completion("0")
                }
            } catch {
                completion("0")
            }
        }.resume()
    }
        
    func getUserHeaders(for users: [User], userid: String, completion: @escaping ([UserHeader]) -> Void) {
        var userHeaders: [UserHeader] = []
        let dispatchGroup = DispatchGroup()
        
        for user in users {
            dispatchGroup.enter()
            getHeaders(for: user._id, userId: userid) { headerId in
                if headerId == "0" {
                    if user.displayname == "" {
                        let userHeader = UserHeader(userId: user._id, email: user.email, displayname: user.username, photo: user.photo, headerId: headerId)
                        userHeaders.append(userHeader)
                    } else {
                        let userHeader = UserHeader(userId: user._id, email: user.email, displayname: user.displayname!, photo: user.photo, headerId: headerId)
                        userHeaders.append(userHeader)
                    }
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(userHeaders)
        }
    }
    
    func updateUser(from apiResponse: User) {
        self.user = apiResponse
    }

    func updateUsers(from apiResponse: [User]) {
        self.users = apiResponse
    }
        
    func getHeaders(from apiResponse: [User], userId: String) {
        getUserHeaders(for: apiResponse, userid: userId) { [weak self] userHeaders in
            self?.userHeaders = userHeaders
        }
    }
}
