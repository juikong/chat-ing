//
//  HeaderStore.swift
//  chat-in
//
//  Created by Juiko Ong on 08/08/2024.
//

import SwiftUI

@MainActor
class HeaderStore: ObservableObject {
    @Published var headers: [Header] = []
    
    func addHeaders(from apiResponse: [Header]) {
        self.headers = []
        self.headers.append(contentsOf: apiResponse)
        saveToLocal()
    }

    func saveToLocal() {
        // Your logic to save the `headers` array to local storage
        // For example, using UserDefaults or a file in the app's documents directory
    }

    func loadFromLocal() {
        // Your logic to load the `headers` array from local storage
    }
}
