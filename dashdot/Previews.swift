//
//  Preview.swift
//  dashdot
//
//  Created by Arden Sinclair on 2023-05-02.
//

import Foundation
import GRDB

enum Previews {
    private static let formatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm, MMM d y"
        return formatter
    }()
    
    static let users = [
        User(id: 1, name: "Arden Sinclair", username: "arden144"),
        User(id: 2, name: "Ray Liu", username: "farayday"),
        User(id: 3, name: "Asar Zuluev", username: "yowu")
    ]
    
    static let chats = [
        Conversation(id: 1, createdAt: formatter.date(from: "04:26, Oct 6 2021")!),
        Conversation(id: 2, createdAt: formatter.date(from: "18:02, Feb 24 2022")!)
    ]
    
    static let members = [
        UserConversation(userId: 1, conversationId: 1),
        UserConversation(userId: 1, conversationId: 2),
        UserConversation(userId: 2, conversationId: 1),
        UserConversation(userId: 3, conversationId: 2),
    ]
    
    static let messages = [
        Message(id: 1, createdAt: formatter.date(from: "04:26, Nov 29 2021")!, body: ".... ../.- .-. -.. . -.", authorId: 2, conversationId: 1),
        Message(id: 2, createdAt: formatter.date(from: "21:59, Dec 31 2021")!, body: "../.-.. --- ...- ./-.-- --- ..-", authorId: 1, conversationId: 1),
        Message(id: 3, createdAt: formatter.date(from: "21:59, Dec 31 2021")!, body: "../.-.. --- ...- ./-.-- --- ..-", authorId: 1, conversationId: 1),
        Message(id: 4, createdAt: formatter.date(from: "21:59, Dec 31 2021")!, body: "../.-.. --- ...- ./-.-- --- ..-", authorId: 1, conversationId: 1),
        Message(id: 5, createdAt: formatter.date(from: "21:59, Dec 31 2021")!, body: "../.-.. --- ...- ./-.-- --- ..-", authorId: 1, conversationId: 1),
        Message(id: 6, createdAt: formatter.date(from: "21:59, Dec 31 2021")!, body: "../.-.. --- ...- ./-.-- --- ..-", authorId: 1, conversationId: 1),
        Message(id: 7, createdAt: formatter.date(from: "21:59, Dec 31 2021")!, body: "../.-.. --- ...- ./-.-- --- ..-", authorId: 1, conversationId: 1),
        Message(id: 8, createdAt: formatter.date(from: "21:59, Dec 31 2021")!, body: "../.-.. --- ...- ./-.-- --- ..-", authorId: 1, conversationId: 1),
        Message(id: 9, createdAt: formatter.date(from: "21:59, Dec 31 2021")!, body: "../.-.. --- ...- ./-.-- --- ..-", authorId: 1, conversationId: 1),
        Message(id: 10, createdAt: formatter.date(from: "21:59, Dec 31 2021")!, body: "../.-.. --- ...- ./-.-- --- ..-", authorId: 1, conversationId: 1)
    ]
}
