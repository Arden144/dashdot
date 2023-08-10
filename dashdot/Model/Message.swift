//
//  Message.swift
//  dashdot
//
//  Created by Arden Sinclair on 2023-04-06.
//

import Foundation
import GRDB
import GRDBQuery
import Combine

struct Message: Identifiable, Equatable, Hashable, Codable, PersistableRecord, FetchableRecord, TableRecord {
    var id: Int32
    var createdAt: Date
    var body: String
    var authorId: Int32
    var conversationId: Int32
    
    static let author = belongsTo(User.self)
    static let conversation = belongsTo(Conversation.self)
    
    static let persistenceConflictPolicy = PersistenceConflictPolicy(insert: .replace, update: .replace)
    
    var author: QueryInterfaceRequest<User> {
        request(for: Message.author)
    }
}

struct DetailedMessage: Identifiable, Equatable, Hashable, Decodable, FetchableRecord {
    var id: Int32 { message.id }
    
    var message: Message
    var authorName: String
    var authorID: Int32
}

extension DetailedMessage {
    struct Request: Queryable {
        static var defaultValue = [DetailedMessage]()
        var conversation: DetailedConversation
        
        func publisher(in database: Database<DatabaseQueue>) -> some Publisher<[DetailedMessage], Error> {
            ValueObservation
                .tracking { db in try conversation.conversation.messages
                    .annotated(withOptional: Message.author
                            .select(
                                Column("name").forKey("authorName"),
                                Column("id").forKey("authorID")
                            ))
                    .asRequest(of: DetailedMessage.self)
                    .fetchAll(db) }
                .publisher(in: database.writer, scheduling: .immediate)
        }
    }
}
