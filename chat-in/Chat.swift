//
//  Chat.swift
//  chat-in
//
//  Created by Juiko Ong on 02/08/2024.
//

import Foundation
import SwiftData

struct ChatMessage: Codable, Identifiable, Hashable {
    var id = UUID()
    var messagesender: String
    var messagerecipient: String
    var messagedepartment: String
    var messagecontent: String
    var messagecreatedat: Date
}

struct ChatGroup: Codable, Identifiable, Hashable {
    var id = UUID()
    var groupname: String
    var groupmessage: String
    var grouptype: String
}

struct ChatUser: Codable, Identifiable, Hashable {
    var id = UUID()
    var email: String
    var username: String
    var photo: String
    var __v: Int
}

struct Header: Codable, Hashable {
    var _id: String
    var sender: String
    var recipient: String
    var department: String?
    var user: String
    var content: String
    var updatedAt: String
    var __v: Int
    
    enum CodingKeys: String, CodingKey {
        case _id
        case sender
        case recipient
        case department
        case user
        case content
        case updatedAt
        case __v = "__v"
    }
}

struct Message: Codable, Hashable {
    var _id: String
    var sender: String
    var recipient: String
    var header: String
    var department: String?
    var content: String
    var createdAt: String
    var __v: Int
    
    enum CodingKeys: String, CodingKey {
        case _id
        case sender
        case recipient
        case header
        case department
        case content
        case createdAt
        case __v = "__v"
    }
}

struct User: Codable, Hashable {
    var _id: String
    var email: String
    var username: String
    var displayname: String?
    var departmentname: String?
    var division: String?
    var location: String?
    var password: String?
    var photo: String
    var __v: Int
    
    enum CodingKeys: String, CodingKey {
        case _id
        case email
        case username
        case displayname
        case departmentname
        case division
        case location
        case password
        case photo
        case __v = "__v"
    }
}

struct Department: Codable, Hashable {
    var _id: String
    var departmentname: String
    var photo: String
    var members: [User]
    var __v: Int
    
    enum CodingKeys: String, CodingKey {
        case _id
        case departmentname
        case photo
        case members
        case __v = "__v"
    }
}

struct ConfigResponse: Codable, Hashable {
    var exists: Bool
    var value: Config?
    
    enum CodingKeys: String, CodingKey {
        case exists
        case value
    }
}

struct Config: Codable, Hashable {
    var _id: String
    var configname: String
    var configvalue: String
    var __v: Int
    
    enum CodingKeys: String, CodingKey {
        case _id
        case configname
        case configvalue
        case __v = "__v"
    }
}

struct UserHeader: Codable, Hashable {
    var userId: String
    var email: String
    var displayname: String
    var photo: String
    var headerId: String
}

struct UpdateUser: Codable, Hashable {
    var email: String
    var displayname: String
    var departmentname: String
    var division: String
    var location: String
}

struct UserPassword: Codable, Hashable {
    var password: String
}
