//
//  ContentCreateDetailView.swift
//  chat-in
//
//  Created by Juiko Ong on 12/08/2024.
//

import SwiftUI

struct ContentCreateDetailView: View {
    var userid: String
    var displayname: String
    var photo: String
    @StateObject private var messageStore = MessageStore()
    @StateObject private var userStore = UserStore()
    @State private var header: String = ""
    @State private var header2: String = ""
    @State private var message: String = ""
    @State private var isSending: Bool = false
    @State private var showAlert = false
    @State private var errorMessage: String?
    @State private var serverurl: String = ""
    @State private var userid2: String = ""
    @State private var usertoken: String = ""
    @State private var chatgptkey: String = ""
    @State private var timer: Timer?
    
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
                                    AsyncMiniUserView(imageUrl: URL(string: "https://\(serverurl)/photos/\(userStore.user.photo)")!)
                                    Text(message.content).font(.title3)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                        .padding()
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                .background(.tertiary)
                            }
                        } else if (message.sender == userid2) {
                            VStack {
                                Text(formatDate(from: message.createdAt))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                HStack {
                                    Text(message.content).font(.title3)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                                        .padding()
                                    AsyncMiniUserView(imageUrl: URL(string: "https://\(serverurl)/photos/\(photo)")!)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                                .background(.tertiary)
                            }
                        }
                    }
                }
                Spacer()
                HStack {
                    Button(action: {
                        sendAIPrompt()
                        sendAIResponse()
                    }) {
                        Text("AI")
                    }
                    .padding(.trailing)
                    .disabled(header.isEmpty || chatgptkey.isEmpty || message.isEmpty)
                    TextField("Messages", text: $message)
                        .padding(.vertical)
                        .padding(.leading)
                        .background(.white)
                    Button(action: {
                        if (header == "") {
                            sendMessage()
                        } else {
                            resendMessage()
                        }
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
                getChatgptKey()
                continueFetchAPIData()
            }
            .onDisappear {
                stopFetchAPIData()
            }
            .navigationTitle(displayname)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Send Error"),
                    message: Text(errorMessage!),
                    dismissButton: .default(Text("OK")) {
                        errorMessage = nil
                    }
                )
            }
        }
    }
    
    private func sendMessage() {
        guard !message.isEmpty else { return }
        isSending = true
        errorMessage = nil
        
        postHeader { result in
            switch result {
            case .success(let headerID):
                header = headerID
                postMessage(headerID: headerID) { result in
                    DispatchQueue.main.async {
                        isSending = false
                        switch result {
                        case .success(_):
                            message = ""
                        case .failure(let error):
                            showAlert = true
                            errorMessage = "Error sending message: \(error.localizedDescription)"
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    showAlert = true
                    isSending = false
                    errorMessage = "Error creating header: \(error.localizedDescription)"
                }
            }
        }
        
        postHeader2 { result in
            switch result {
            case .success(let headerID2):
                header2 = headerID2
                postMessage2(headerID2: headerID2) { result in
                    DispatchQueue.main.async {
                        isSending = false
                        switch result {
                        case .success(_):
                            message = ""
                            fetchAPIData()
                        case .failure(let error):
                            showAlert = true
                            errorMessage = "Error sending message: \(error.localizedDescription)"
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    showAlert = true
                    isSending = false
                    errorMessage = "Error creating header: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func resendMessage() {
        guard !message.isEmpty else { return }
        isSending = true
        errorMessage = nil
        
        updateHeader { result in
            switch result {
            case .success(let headerID):
                postMessage(headerID: headerID) { result in
                    DispatchQueue.main.async {
                        isSending = false
                        switch result {
                        case .success(_):
                            message = ""
                        case .failure(let error):
                            errorMessage = "Error sending message: \(error.localizedDescription)"
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    showAlert = true
                    isSending = false
                    errorMessage = "Error creating header: \(error.localizedDescription)"
                }
            }
        }
        
        updateHeader2 { result in
            switch result {
            case .success(let headerID2):
                postMessage2(headerID2: headerID2) { result in
                    DispatchQueue.main.async {
                        isSending = false
                        switch result {
                        case .success(_):
                            message = ""
                            fetchAPIData()
                        case .failure(let error):
                            errorMessage = "Error sending message: \(error.localizedDescription)"
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    showAlert = true
                    isSending = false
                    errorMessage = "Error creating header: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // API call to post a new header
    private func postHeader(completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://\(serverurl)/headers") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(usertoken)", forHTTPHeaderField: "Authorization")
        
        let headerData = [
            "content": message,
            "senderId": userid2,
            "recipientId": userid,
            "departmentId": "0",
            "userId": userid2
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: headerData)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let headerID = json["_id"] as? String else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
                completion(.failure(error))
                return
            }
            
            completion(.success(headerID))
        }.resume()
    }
    
    // API call to update header
    private func updateHeader(completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://\(serverurl)/headers/\(header)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(usertoken)", forHTTPHeaderField: "Authorization")
        
        let headerData = [
            "content": message,
            "senderId": userid2,
            "recipientId": userid
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: headerData)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let headerID = json["_id"] as? String else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
                completion(.failure(error))
                return
            }
            
            completion(.success(headerID))
        }.resume()
    }
    
    // API call to post a new message
    private func postMessage(headerID: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://\(serverurl)/messages") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(usertoken)", forHTTPHeaderField: "Authorization")
        
        let messageData = [
            "content": message,
            "senderId": userid2,
            "recipientId": userid,
            "departmentId": "0",
            "headerId": headerID,
            "fileId": "0"
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: messageData)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let messageID = json["header"] as? String else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
                completion(.failure(error))
                return
            }
            
            completion(.success(messageID))
        }.resume()
    }
    
    // API call to post a new recipient header
    private func postHeader2(completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://\(serverurl)/headers") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(usertoken)", forHTTPHeaderField: "Authorization")
        
        let headerData = [
            "content": message,
            "senderId": userid2,
            "recipientId": userid,
            "departmentId": "0",
            "userId": userid
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: headerData)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let headerID2 = json["_id"] as? String else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
                completion(.failure(error))
                return
            }
            
            completion(.success(headerID2))
        }.resume()
    }
    
    // API call to update recipient header
    private func updateHeader2(completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://\(serverurl)/headers/\(header2)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(usertoken)", forHTTPHeaderField: "Authorization")
        
        let headerData = [
            "content": message,
            "senderId": userid2,
            "recipientId": userid
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: headerData)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let headerID = json["_id"] as? String else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
                completion(.failure(error))
                return
            }
            
            completion(.success(headerID))
        }.resume()
    }
    
    // API call to post a new recipient message
    private func postMessage2(headerID2: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://\(serverurl)/messages") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(usertoken)", forHTTPHeaderField: "Authorization")
        
        let messageData = [
            "content": message,
            "senderId": userid2,
            "recipientId": userid,
            "departmentId": "0",
            "headerId": headerID2,
            "fileId": "0"
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: messageData)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let messageID2 = json["header"] as? String else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
                completion(.failure(error))
                return
            }
            
            completion(.success(messageID2))
        }.resume()
    }
    
    func sendAIPrompt() {
        postChatGPTPrompt()
        postChatGPTPrompt2()
    }
        
    // API call to post a new message
    func postChatGPTPrompt() {
        let url = URL(string: "https://\(serverurl)/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(usertoken)", forHTTPHeaderField: "Authorization")
        
        let messageData = [
            "content": "[AI Prompt] " + message,
            "senderId": userid2,
            "recipientId": userid,
            "departmentId": "0",
            "headerId": header,
            "fileId": "0"
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: messageData)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
        }.resume()
    }
    
    // API call to post a new recipient message
    func postChatGPTPrompt2() {
        let url = URL(string: "https://\(serverurl)/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(usertoken)", forHTTPHeaderField: "Authorization")
        
        let messageData = [
            "content": "[AI Prompt] " + message,
            "senderId": userid2,
            "recipientId": userid,
            "departmentId": "0",
            "headerId": header2,
            "fileId": "0"
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: messageData)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
        }.resume()
    }
    
    func sendAIResponse() {
        callChatGPTAPI { content in
            if let content = content {
                updateChatGPTHeader()
                postChatGPTMessage(content)
                updateChatGPTHeader2()
                postChatGPTMessage2(content)
                fetchAPIData()
            } else {
                print("Failed to get content from OpenAI API.")
            }
        }
    }
    
    // Call ChatGPT API
    func callChatGPTAPI(completion: @escaping (String?) -> Void) {
        let apiKey = chatgptkey
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [["role": "user", "content": message]]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error calling OpenAI API: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String {
                completion(content)
            } else {
                print("Failed to parse OpenAI API response.")
                completion(nil)
            }
        }.resume()
    }
    
    // API call to update header
    func updateChatGPTHeader() {
        let url = URL(string: "https://\(serverurl)/headers/\(header)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(usertoken)", forHTTPHeaderField: "Authorization")
        
        let headerData = [
            "content": "[AI Response]",
            "senderId": userid2,
            "recipientId": userid
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: headerData)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
        }.resume()
    }
        
    // API call to post a new message
    func postChatGPTMessage(_ aimessage: String) {
        let url = URL(string: "https://\(serverurl)/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(usertoken)", forHTTPHeaderField: "Authorization")
        
        let messageData = [
            "content": "[AI Response] " + aimessage,
            "senderId": userid2,
            "recipientId": userid,
            "departmentId": "0",
            "headerId": header,
            "fileId": "0"
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: messageData)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
        }.resume()
    }
    
    // API call to update recipient header
    func updateChatGPTHeader2() {
        let url = URL(string: "https://\(serverurl)/headers/\(header2)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(usertoken)", forHTTPHeaderField: "Authorization")
        
        let headerData = [
            "content": "[AI Response]",
            "senderId": userid2,
            "recipientId": userid
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: headerData)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
        }.resume()
    }
        
    // API call to post a new recipient message
    func postChatGPTMessage2(_ aimessage: String) {
        let url = URL(string: "https://\(serverurl)/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(usertoken)", forHTTPHeaderField: "Authorization")
        
        let messageData = [
            "content": "[AI Response] " + aimessage,
            "senderId": userid2,
            "recipientId": userid,
            "departmentId": "0",
            "headerId": header2,
            "fileId": "0"
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: messageData)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
        }.resume()
    }
    
    func getServerUrl() {
        serverurl = UserDefaults.standard.string(forKey: "serverurl") ?? ""
    }
    
    func getUserId() {
        userid2 = UserDefaults.standard.string(forKey: "UserId") ?? "0"
        usertoken = UserDefaults.standard.string(forKey: "accessToken") ?? "0"
    }
    
    private func getChatgptKey() {
        guard let url = URL(string: "https://\(serverurl)/adminconfigs/CHATGPT_KEY") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(usertoken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(ConfigResponse.self, from: data)
                if decodedResponse.exists {
                    if let configValue = decodedResponse.value {
                        DispatchQueue.main.async {
                            chatgptkey = configValue.configvalue
                        }
                    }
                } else {
                    print("Config does not exist.")
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
    
    func fetchAPIData() {
        guard let url = URL(string: "https://\(serverurl)/messages/by-header?headerId=\(header)") else { return }

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
        guard let url = URL(string: "https://\(serverurl)/users/user/\(userid2)") else { return }

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
    ContentCreateDetailView(userid: "66ac483a9f7041b43eb34f79", displayname: "john_c", photo: "photo.png")
}
