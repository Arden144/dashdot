//
//  UserConversation.swift
//  dashdot
//
//  Created by Arden Sinclair on 2023-04-07.
//

import Foundation
import GRDB

struct UserConversation: Codable, PersistableRecord, FetchableRecord, TableRecord {
    var userId: Int32
    var conversationId: Int32
    
    static let user = belongsTo(User.self)
    static let conversation = belongsTo(Conversation.self)
    
    static let persistenceConflictPolicy = PersistenceConflictPolicy(insert: .replace, update: .replace)
}
