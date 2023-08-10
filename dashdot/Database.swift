//
//  Database.swift
//  dashdot
//
//  Created by Arden Sinclair on 2023-05-01.
//

import GRDB
import GRDBQuery
import SwiftUI

struct Database<Writer: DatabaseWriter> {
    let writer: Writer
    
    fileprivate init(writer: Writer) {
        try! migration.migrate(writer)
        self.writer = writer
    }
    
    func read<T>(_ value: (GRDB.Database) throws -> T) throws -> T {
        try writer.read(value)
    }
    
    func read<T>(_ value: @Sendable @escaping (GRDB.Database) throws -> T) async throws -> T {
        try await writer.read(value)
    }
}

extension Database<DatabaseQueue> {
    static let shared = createSharedDatabase()
    static let preview = createPreviewDatabase()
}

private struct DatabaseKey: EnvironmentKey {
    static var defaultValue: Database = .preview
}

extension EnvironmentValues {
    var db: Database<DatabaseQueue> {
        get { self[DatabaseKey.self] }
        set { self[DatabaseKey.self] = newValue }
    }
}

extension View {
    func database(_ db: Database<DatabaseQueue>) -> some View {
        environment(\.db, db)
    }
}

extension Query where Request.DatabaseContext == Database<DatabaseQueue> {
    init(_ request: Request) {
        self.init(request, in: \.db)
    }
}

private func createDatabaseFile() throws -> URL {
    let supportDir = try FileManager.default.url(
        for: .applicationSupportDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
    )
    
    let dbDir = supportDir.appendingPathComponent("data", isDirectory: true)
    try FileManager.default.createDirectory(at: dbDir, withIntermediateDirectories: true)
    
    return dbDir.appendingPathComponent("db.sqlite")
}

private func createSharedDatabase() -> Database<DatabaseQueue> {
    do {
        let dbFile = try createDatabaseFile()
        try? FileManager.default.removeItem(at: dbFile) // DELETES DATABASE ON LAUNCH
        let dbQueue = try DatabaseQueue(path: dbFile.path)
        return Database(writer: dbQueue)
    } catch(let error) {
        fatalError("error initializing database: \(error)")
    }
}

private func createPreviewDatabase() -> Database<DatabaseQueue> {
    do {
        let dbQueue = try DatabaseQueue()
        let database = Database(writer: dbQueue)
        try fillPreviewData(writer: database.writer)
        return database
    } catch(let error) {
        fatalError("error initializing preview database: \(error)")
    }
}

private func fillPreviewData(writer: some DatabaseWriter) throws {
    try writer.write { db in
        try Previews.users.forEach { user in
            try user.insert(db)
        }

        try Previews.chats.forEach { conversation in
            try conversation.insert(db)
        }

        try Previews.members.forEach { userConversation in
            try userConversation.insert(db)
        }

        try Previews.messages.forEach { message in
            try message.insert(db)
        }
    }
}
