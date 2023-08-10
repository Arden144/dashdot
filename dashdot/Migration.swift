//
//  Migration.swift
//  dashdot
//
//  Created by Arden Sinclair on 2023-05-01.
//

import Foundation
import GRDB

let migration = {
    var migrator = DatabaseMigrator()
    
    migrator.registerMigration("createUsers") { db in
        try db.create(table: "user") { t in
            t.primaryKey("id", .integer)
            t.column("name", .text).notNull()
            t.column("username", .text).notNull()
        }
    }
    
    migrator.registerMigration("createConversations") { db in
        try db.create(table: "conversation") { t in
            t.primaryKey("id", .integer)
            t.column("createdAt", .datetime).notNull()
        }
    }
    
    migrator.registerMigration("createMessages") { db in
        try db.create(table: "message") { t in
            t.primaryKey("id", .integer)
            t.column("createdAt", .datetime).notNull()
            t.column("body", .text).notNull()
            t.column("authorId", .integer)
                .notNull()
                .indexed()
                .references("user")
            t.column("conversationId", .integer)
                .notNull()
                .indexed()
                .references("conversation")
        }
    }
    
    migrator.registerMigration("createUserConversations") { db in
        try db.create(table: "userConversation") { t in
            t.primaryKey {
                t.column("userId", .integer)
                    .notNull()
                    .indexed()
                    .references("user")
                t.column("conversationId", .integer)
                    .notNull()
                    .indexed()
                    .references("conversation")
            }
        }
    }
    
    return migrator
}()
