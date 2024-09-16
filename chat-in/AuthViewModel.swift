//
//  AuthViewModel.swift
//  chat-in
//
//  Created by Juiko Ong on 30/08/2024.
//

import SwiftUI
import Combine

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isAutologin: Bool = true
    
    func logIn() {
        // Perform login logic
        isAuthenticated = true
    }
    
    func logOut() {
        // Perform logout logic
        isAuthenticated = false
        isAutologin = false
    }
    
    func reLogIn() {
        isAuthenticated = false
    }
    
    //func rememberLogIn() {
    //    isAutologin = true
    //}
}
