//
//  dashdotApp.swift
//  dashdot
//
//  Created by Arden Sinclair on 2023-03-28.
//

import Connect
import SwiftUI
import GRDB
import GRDBQuery
import Observation
import UserNotifications
import OSLog

struct TaskID: Equatable {
    var session: Session?
    var scenePhase: ScenePhase
}

@main
struct dashdotApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var toastManager = ToastManager.shared
    @State private var sessionManager = SessionManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView(userID: sessionManager.session?.userID)
                .database(.shared)
                .environment(sessionManager)
                .environment(toastManager)
                .task(id: TaskID(session: sessionManager.session, scenePhase: scenePhase)) {
                    await Sync.start(writer: Database.shared.writer, scenePhase: scenePhase)
                }
        }
    }
}
