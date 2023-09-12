//
//  Database.swift
//  dashdot
//
//  Created by Arden Sinclair on 2023-05-01.
//

import GRDB
import GRDBQuery
import SwiftUI
import OSLog

struct Database {
    let writer: any DatabaseWriter
    
    fileprivate init(writer: any DatabaseWriter) {
        self.writer = writer
    }
    
    func read<T>(_ value: (GRDB.Database) throws -> T) throws -> T {
        try writer.read(value)
    }
    
    func read<T>(_ value: @Sendable @escaping (GRDB.Database) throws -> T) async throws -> T {
        try await writer.read(value)
    }
}

extension Database {
    static let logger = Logger(subsystem: "com.ardensinclair.dashdot", category: "Database")
    
    static let shared = createSharedDatabase(logger: logger)
    static let preview = createPreviewDatabase()
}

private struct DatabaseKey: EnvironmentKey {
    static var defaultValue: Database = .preview
}

extension EnvironmentValues {
    var db: Database {
        get { self[DatabaseKey.self] }
        set { self[DatabaseKey.self] = newValue }
    }
}

extension View {
    func database(_ db: Database) -> some View {
        environment(\.db, db)
    }
}

extension Query where Request.DatabaseContext == Database {
    init(_ request: Request) {
        self.init(request, in: \.db)
    }
}

enum SetupError: Error {
    case invalidAppGroup
    case migrationTooRecent
}

private func getDatabaseURL() throws -> URL {
    guard let supportDir = FileManager
        .default
        .containerURL(forSecurityApplicationGroupIdentifier: "group.com.ardensinclair.dashdot")
    else { throw SetupError.invalidAppGroup }
    
    let dbDir = supportDir.appendingPathComponent("data", isDirectory: true)
    try FileManager.default.createDirectory(at: dbDir, withIntermediateDirectories: true)
    
    return dbDir.appendingPathComponent("db.sqlite")
}

private func coordinatedWrite<T>(at url: URL, closure: (URL) throws -> T) throws -> T {
    let coordinator = NSFileCoordinator(filePresenter: nil)
    var coordinatorError: NSError?
    var closureResult: T?
    var closureError: Error?
    coordinator.coordinate(writingItemAt: url, options: .forMerging, error: &coordinatorError) { url in
        do { closureResult = try closure(url) }
        catch { closureError = error }
    }
    if let coordinatorError { throw coordinatorError }
    if let closureError { throw closureError }
    return closureResult!
}

private func createDatabase(at url: URL) throws -> DatabasePool {
    var configuration = Configuration()
    configuration.prepareDatabase { db in
        var flag: CInt = 1
        let code = withUnsafeMutablePointer(to: &flag) { flagP in
            sqlite3_file_control(db.sqliteConnection, nil, SQLITE_FCNTL_PERSIST_WAL, flagP)
        }
        guard code == SQLITE_OK else {
            throw DatabaseError(resultCode: ResultCode(rawValue: code))
        }
    }
    let dbPool = try DatabasePool(path: url.path, configuration: configuration)
    try migration.migrate(dbPool)
    if try dbPool.read(migration.hasBeenSuperseded) {
        throw SetupError.migrationTooRecent
    }
    
    return dbPool
}

func createSharedDatabase(logger: Logger) -> Database {
    do {
        let dbFile = try getDatabaseURL()
        
        let db = try coordinatedWrite(at: dbFile) { url in
            try? FileManager.default.removeItem(at: url)
            return try createDatabase(at: url)
        }
        
        return Database(writer: db)
    } catch {
        logger.error("Failed to create database: \(error, privacy: .public)")
        fatalError()
    }
}

private func createPreviewDatabase() -> Database {
    do {
        let dbQueue = try DatabaseQueue()
        try migration.migrate(dbQueue)
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
