//
//  Conversation.swift
//  dashdot
//
//  Created by Arden Sinclair on 2023-04-06.
//

import Foundation
import GRDB
import GRDBQuery
import Combine

struct Conversation: Identifiable, Equatable, Hashable, Codable, PersistableRecord, FetchableRecord, TableRecord {
    var id: Int32
    var createdAt: Date
    
    static let messages = hasMany(Message.self).order(Column("createdAt"))
    static let members = hasMany(User.self, through: hasMany(UserConversation.self), using: UserConversation.user)
    
    static let persistenceConflictPolicy = PersistenceConflictPolicy(insert: .replace, update: .replace)
    
    var messages: QueryInterfaceRequest<Message> {
        request(for: Conversation.messages)
    }
    
    var members: QueryInterfaceRequest<User> {
        request(for: Conversation.members)
    }
}

struct DetailedConversation: Identifiable, Equatable, Hashable, Decodable, FetchableRecord {
    var id: Int32 { conversation.id }
    
    var conversation: Conversation
    var latestMessage: Message?
    var members: [User]
}

extension DetailedConversation {
    private static let latestMessageCTE = CommonTableExpression(
        named: "latestMessage",
        request: Message
            .annotated(with: max(Column("createdAt")))
            .group(Column("conversationId"))
    )
    
    private static let latestMessage = Conversation.association(
        to: latestMessageCTE,
        on: { chat, latestMessage in
            chat[Column("id")] == latestMessage[Column("conversationId")]
        }
    )
    
    static var request: QueryInterfaceRequest<DetailedConversation> {
        Conversation
            .with(latestMessageCTE)
            .including(optional: latestMessage)
            .including(all: Conversation.members.forKey("members"))
            .asRequest(of: DetailedConversation.self)
    }
    
    struct Request: Queryable {
        static var defaultValue = [DetailedConversation]()
        
        func publisher(in database: Database) -> some Publisher<[DetailedConversation], Error> {
            ValueObservation
                .tracking { db in try DetailedConversation.request.fetchAll(db) }
                .publisher(in: database.writer, scheduling: .immediate)
        }
    }
}
