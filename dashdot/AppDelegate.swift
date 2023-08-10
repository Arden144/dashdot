//
//  AppDelegate.swift
//  dashdot
//
//  Created by Arden Sinclair on 2023-08-04.
//

import UIKit
import OSLog

class AppDelegate: NSObject, UIApplicationDelegate {
    static let logger = Logger(subsystem: "com.ardensinclair.dashdot", category: "AppDelegate")
    static let client = Api_PushClient.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UIApplication.shared.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Self.logger.info("Got remote notifications token")
        Task {
            var request = Push_Register()
            request.deviceToken = deviceToken
            let response = await Self.client.register(request: request)
            switch response.result {
            case .success(_):
                Self.logger.notice("Registered for push notifications successfully")
            case .failure(let error):
                Self.logger.error("Failed to register for push notifications: \(error, privacy: .public)")
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Self.logger.error("Failed to get remote notifications token: \(error, privacy: .public)")
    }
}
