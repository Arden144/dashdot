//
//  LoginView.swift
//  dashdot
//
//  Created by Arden Sinclair on 2023-04-09.
//

import SwiftUI
import AuthenticationServices
import OSLog

extension LoginView {
    private static let logger = Logger(subsystem: "com.ardensinclair.dashdot", category: "Sign in with Apple")
    
    func siwaOnRequest(request: ASAuthorizationAppleIDRequest) {
        Self.logger.info("Sign in requested")
        request.requestedScopes = [.fullName, .email]
    }
    
    func siwaOnCompletion(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                Self.logger.fault("Completion handler got the wrong credential type")
                return
            }
            
            Self.logger.notice("Sign in successful")
            
            Task {
                var request = Auth_NewAuth()
                request.identityToken = String.init(decoding: credential.identityToken!, as: UTF8.self)
                request.authorizationCode = String.init(decoding: credential.authorizationCode!, as: UTF8.self)
                request.fullName = credential.fullName?.formatted() ?? "User"
                request.email = credential.email ?? ""
                
                let session = await Auth.handleAuthRequest(request: request)
                SessionManager.shared.session = session
                if let session {
                    ToastManager.shared.add(Toast(title: "Signed In", desc: "Welcome ID \(session.userID)") {
                        Image(systemName: "person.crop.circle.badge.checkmark")
                    })
                } else {
                    status = "Something went wrong. Try again later"
                }
            }
        case .failure(let error):
            Self.logger.error("Sign in failed: \(error, privacy: .public)")
        }
    }
}

struct LoginView: View {
    @State private var status: String?
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Text("-.")
                .font(.custom("Dashdot-Regular", fixedSize: 64))
            Spacer()
            if let status {
                Text(status)
                    .padding()
            }
            SignInWithAppleButton(
                onRequest: { siwaOnRequest(request: $0) },
                onCompletion: { siwaOnCompletion(result: $0) }
            )
            .frame(width: 260.0, height: 64.0)
            Spacer()
        }
    }
}

#Preview {
    @State var sessionManager = SessionManager.shared
    @State var toastManager = ToastManager.shared
    
    return LoginView()
        .environment(sessionManager)
        .environment(toastManager)
}
