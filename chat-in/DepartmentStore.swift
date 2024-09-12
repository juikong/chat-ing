//
//  DepartmentStore.swift
//  chat-in
//
//  Created by Juiko Ong on 12/08/2024.
//

import SwiftUI

@MainActor
class DepartmentStore: ObservableObject {
    @Published var department: Department = Department(_id: "0", departmentname: "IT Department", photo: "group-photo.png", members: [], __v: 0)
    
    func updateDepartment(from apiResponse: Department) {
        self.department = apiResponse
    }

    func saveToLocal() {
        // Your logic to save the `departments` array to local storage
        // For example, using UserDefaults or a file in the app's documents directory
    }

    func loadFromLocal() {
        // Your logic to load the `departments` array from local storage
    }
}
