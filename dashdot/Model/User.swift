//
//  User.swift
//  dashdot
//
//  Created by Arden Sinclair on 2023-04-06.
//

import Foundation
import GRDB
import GRDBQuery
import Combine

struct User: Identifiable, Equatable, Hashable, Codable, PersistableRecord, FetchableRecord, TableRecord {
    var id: Int32
    var name: String
    var username: String
    
    static let messages = hasMany(Message.self)
    static let conversations = hasMany(Conversation.self, through: User.hasMany(UserConversation.self), using: UserConversation.conversation)
    
    static let persistenceConflictPolicy = PersistenceConflictPolicy(insert: .replace, update: .replace)
}

extension User {
    struct Request: Queryable {
        var userID: Int?
        
        static var defaultValue: User? = nil
        
        func publisher(in database: Database<DatabaseQueue>) -> some Publisher<User?, Error> {
            ValueObservation
                .tracking { db in
                    guard let userID = userID else { return nil }
                    return try User.fetchOne(db, id: Int32(userID))
                }
                .publisher(in: database.writer, scheduling: .immediate)
        }
    }
}
