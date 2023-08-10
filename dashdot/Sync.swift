//
//  Sync.swift
//  dashdot
//
//  Created by Arden Sinclair on 2023-05-01.
//

import GRDB
import Connect
import SwiftProtobuf
import SwiftUI
import OSLog

enum Sync {
    private static let client = Api_ChatClient.shared
    private static let logger = Logger(subsystem: "com.ardensinclair.dashdot", category: "Sync")
    private static let input = {
        var request = Sync_SyncInfo()
        request.lastUpdated = SwiftProtobuf.Google_Protobuf_Timestamp(date: .distantPast)
        return request
    }()
    
    @MainActor private static var syncTask: Task<(), Error>? = nil
    @MainActor private static var syncErrorToast: Toast?
    @MainActor private static var syncTaskId = 0
    
    @MainActor private static func reportSyncError() {
        if UIApplication.shared.applicationState != .active { return }
        if syncErrorToast != nil { return }
        let toast = Toast(title: "No Connection", desc: "Trying again in a moment", persistent: true) {
            Image(systemName: "exclamationmark.triangle")
        }
        syncErrorToast = toast
        ToastManager.shared.add(toast)
    }
    
    @MainActor private static func clearSyncError() {
        guard let syncErrorToast else { return }
        ToastManager.shared.remove(syncErrorToast)
        self.syncErrorToast = nil
    }
    
    @MainActor static func start(writer: some DatabaseWriter, scenePhase: ScenePhase) async {
        if let syncTask {
            syncTask.cancel()
            self.syncTask = nil
            logger.info("Cancelled old sync task")
        }
        
        if SessionManager.shared.session == nil || scenePhase != .active {
            logger.info("Scene phase is \(String(describing: scenePhase)), not starting a new sync task")
            return
        }
        
        let id = syncTaskId
        syncTaskId += 1
        logger.info("Starting new sync task id \(id)")
        
        syncTask = Task.detached {
            while !Task.isCancelled {
                do {
                    let request = client.sync()
                    
                    async let task = Task {
                        for await result in request.results() {
                            if Task.isCancelled { break }
                            switch result {
                            case .complete(code: let code, error: let error, _):
                                try await self.onComplete(id: id, code: code, error: error)
                            case .message(let message):
                                logger.info("Received sync message on id \(id)")
                                await clearSyncError()
                                try await self.onMessage(id: id, writer: writer, message: message)
                            case .headers(_):
                                break
                            }
                        }
                    }
                    
                    logger.info("Sending a sync request on id \(id)")
                    
                    try request.send(input)
                    try await task.value
                } catch {
                    logger.error("Sync task id \(id) failed: \(error, privacy: .public)")
                    await reportSyncError()
                    try await Task.sleep(for: .seconds(5))
                }
            }
        }
    }
    
    private static func onMessage(id: Int, writer: some DatabaseWriter, message: Sync_Events) async throws {
        try await writer.write { db in
            for event in message.events {
                switch event.type {
                case .some(.chat(let chat)):
//                    logger.info("Adding chat (\(chat.id))")
                    try Conversation(id: chat.id, createdAt: chat.date.date)
                        .insert(db)
                case .some(.msg(let msg)):
//                    logger.info("Adding msg (\(msg.id))")
                    try Message(id: msg.id, createdAt: msg.date.date, body: msg.text, authorId: msg.userID, conversationId: msg.chatID)
                        .insert(db)
                case .some(.user(let user)):
//                    logger.info("Adding user (\(user.id))")
                    try User(id: user.id, name: user.name, username: user.username)
                        .insert(db)
                case .some(.member(let member)):
//                    logger.info("Adding member (user: \(member.userID), chat: \(member.chatID))")
                    try UserConversation(userId: member.userID, conversationId: member.chatID)
                        .insert(db)
                case .none:
                    logger.warning("Received event with no data on id \(id)")
                }
            }
        }
    }
    
    private static func onComplete(id: Int, code: Code, error: Error?) async throws {
        switch code {
        case .ok:
            logger.info("Sync ended normally on id \(id)")
        case .permissionDenied:
            logger.notice("Sync ended from permission denied error on id \(id)")
            SessionManager.shared.session = await Auth.sendRenewRequest(session: SessionManager.shared.session)
        case .unauthenticated:
            logger.notice("Sync ended from unauthenticated error on id \(id)")
            SessionManager.shared.session = nil
        default:
            if let error {
                logger.error("Sync ended with an unexpected error: (id: \(id), code: \(code.name, privacy: .public), error: \(error, privacy: .public))")
            } else {
                logger.error("Sync ended with an unexpected code: (id: \(id), code: \(code.name, privacy: .public))")
            }
            
            await reportSyncError()
            
            do {
                try await Task.sleep(for: .seconds(5))
            } catch {}
        }
    }
}
