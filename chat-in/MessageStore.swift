//
//  MessageStore.swift
//  chat-in
//
//  Created by Juiko Ong on 08/08/2024.
//

import SwiftUI

@MainActor
class MessageStore: ObservableObject {
    @Published var messages: [Message] = []
    
    func addMessages(from apiResponse: [Message]) {
        self.messages = apiResponse
    }

    func saveToLocal() {
        // Your logic to save the `messages` array to local storage
        // For example, using UserDefaults or a file in the app's documents directory
    }

    func loadFromLocal() {
        // Your logic to load the `messages` array from local storage
    }
}
