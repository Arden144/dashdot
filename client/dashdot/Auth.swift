//
//  Client.swift
//  dashdot
//
//  Created by Arden Sinclair on 2023-05-02.
//

import SwiftUI
import OSLog

enum Auth {
    private static let logger = Logger(subsystem: "com.ardensinclair.dashdot", category: "Auth")
    private static let client = Api_AuthClient.shared
    
    static func handleAuthRequest(request: Auth_NewAuth) async -> Session? {
        logger.info("Sending authorization request to the server")
        
        let response = await client.auth(request: request)
        
        switch response.result {
        case .success(let message):
            logger.notice("Authorized user '\(message.userID)'")
            return Session(
                accessToken: message.accessToken,
                refreshToken: message.refreshToken,
                userID: Int(message.userID)
            )
        case .failure(let error):
            logger.error("Authorization failed: \(error, privacy: .public)")
            return nil
        }
    }
    
    static func sendRenewRequest(session: Session?) async -> Session? {
        logger.info("Trying to renew session")
        
        guard let session else {
            logger.fault("Tried to renew session with a nil session")
            return nil
        }
        
        logger.info("Sending renew request to the server")
        
        var request = Auth_Renew()
        request.refreshToken = session.refreshToken
        
        while !Task.isCancelled {
            let response = await client.renew(request: request)
            
            switch response.result {
            case .success(let message):
                logger.notice("Successfully renewed user '\(message.userID)'")
                return Session(
                    accessToken: message.accessToken,
                    refreshToken: message.refreshToken,
                    userID: Int(message.userID)
                )
            case .failure(let error):
                switch error.code {
                case .permissionDenied:
                    logger.notice("Renewal failed from permission denied error")
                    return nil
                default:
                    logger.error("Renewal failed from unknown error: \(error, privacy: .public)")
                }
            }
            
            do {
                logger.info("Waiting 5 seconds before trying renewal again")
                try await Task.sleep(for: .seconds(5))
            } catch {
                break
            }
        }
        
        return nil
    }
}
