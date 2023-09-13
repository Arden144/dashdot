//
//  Session.swift
//  dashdot
//
//  Created by Arden Sinclair on 2023-05-27.
//

import SwiftUI

struct Session: Equatable, Codable {
    let accessToken: String
    let refreshToken: String
    let userID: Int
}

extension Session {
    static let preview = Session(accessToken: "", refreshToken: "", userID: Int(Previews.users[0].id))
}

@Observable class SessionManager {
    static let shared = SessionManager()
    
    var session: Session? {
        didSet {
            if let session {
                Keychain.save(session, service: "session")
            } else {
                Keychain.delete(service: "session")
            }
            
        }
    }
    
    private init() {
        self.session = Keychain.read(service: "session", type: Session.self)
    }
}
