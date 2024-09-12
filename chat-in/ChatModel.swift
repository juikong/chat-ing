//
//  ChatModel.swift
//  chat-in
//
//  Created by Juiko Ong on 02/08/2024.
//

import Foundation

struct ChatModel {
    let chatMessage1 = [
        ChatMessage(messagesender: "Richard", messagerecipient: "Rocky", messagedepartment: "-", messagecontent: "What's up?", messagecreatedat: Date()), ChatMessage(messagesender: "Rocky", messagerecipient: "Richard", messagedepartment: "-", messagecontent: "Cooking", messagecreatedat: Date())
    ]
    let chatMessage2 = [
        ChatMessage(messagesender: "Rocky", messagerecipient: "John", messagedepartment: "-", messagecontent: "Cooking", messagecreatedat: Date()), ChatMessage(messagesender: "John", messagerecipient: "Rocky", messagedepartment: "-", messagecontent: "See me", messagecreatedat: Date())
    ]
    let chatMessage3 = [
        ChatMessage(messagesender: "Rocky", messagerecipient: "*", messagedepartment: "IT Department", messagecontent: "Full Ham", messagecreatedat: Date()),
        ChatMessage(messagesender: "hhh", messagerecipient: "Rocky", messagedepartment: "IT Department", messagecontent: "Let's Start", messagecreatedat: Date())
    ]
    let chatGroup = [
        ChatGroup(groupname: "Richard", groupmessage: "Cooking", grouptype: "Single"), ChatGroup(groupname: "John", groupmessage: "See me", grouptype: "Single"), ChatGroup(groupname: "IT Department", groupmessage: "Let's start", grouptype: "Group")
    ]
    let chatUser = [
        ChatUser(email: "john@rookiess.shop", username: "john_c", photo: "photo.png", __v: 0),
        ChatUser(email: "rocky@rookiess.shop", username: "rocky_d", photo: "photo.png", __v: 0),
        ChatUser(email: "hhh@rookiess.shop", username: "3_h", photo: "photo.png", __v: 0)
    ]
}
