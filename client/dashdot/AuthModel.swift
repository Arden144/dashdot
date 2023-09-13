////
////  Auth.swift
////  dashdot
////
////  Created by Arden Sinclair on 2023-03-29.
////
//
//import SwiftUI
//import Connect
//import Foundation
//import AuthenticationServices
//
//final class AuthModel: ObservableObject {
//    private var global: dashdotApp.Model
//    private var client: Auth_AuthClient
//    @KeychainStorage("refreshToken") private var refreshToken: String?
//
//    init(global: dashdotApp.Model, client: ProtocolClient) {
//        self.global = global
//        self.client = Auth_AuthClient(client: client)
//    }
//
//    @MainActor private func signIn(_ message: Auth_AuthResponse) {
//        global.userID = Int(message.userID)
//        global.accessToken = message.accessToken
//        refreshToken = message.refreshToken
//    }
//
//    @MainActor func signOut() {
//        global.userID = nil
//        global.accessToken = nil
//        refreshToken = nil
//    }
//
//    func renewTokens() async throws {
//        guard let refreshToken = refreshToken else {
//            print("no refresh token, signing out")
//            await signOut()
//            return
//        }
//
//        var request = Auth_RenewRequest()
//        request.refreshToken = refreshToken
//
//        while !Task.isCancelled && global.userID != nil {
//            print("sending renew request")
//            let response = await client.renew(request: request)
//            switch response.result {
//            case .success(let message):
//                print("renewed successfully, updating with new tokens")
//                await signIn(message)
//                break
//            case .failure(let error):
//                switch error.code {
//                case .permissionDenied:
//                    print("permission denied, signing out")
//                    await signOut()
//                    break
//                default:
//                    print("other error renewing tokens, trying again in 3s")
//                    await global.displayError(error)
//                    try await Task.sleep(for: .seconds(3))
//                }
//            }
//        }
//    }
//
//    func onRequest(request: ASAuthorizationAppleIDRequest) {
//        request.requestedScopes = [.fullName, .email]
//    }
//
//    func onCompletion(result: Result<ASAuthorization, Error>) {
//        switch result {
//        case .success(let authorization):
//            guard let authResult = authorization.credential as? ASAuthorizationAppleIDCredential else {
//                assertionFailure("sign in with apple completion handler got the wrong credential")
//                return
//            }
//
//            var partialRequest = Auth_AuthRequest()
//            partialRequest.identityToken = String.init(decoding: authResult.identityToken!, as: UTF8.self)
//            partialRequest.authorizationCode = String.init(decoding: authResult.authorizationCode!, as: UTF8.self)
//            partialRequest.fullName = authResult.fullName?.formatted() ?? "User"
//            partialRequest.email = authResult.email ?? ""
//            let request = partialRequest
//
//            Task(priority: .high) {
//                let response = await client.auth(request: request)
//                switch response.result {
//                case .success(let message):
//                    print("issuing tokens successful, signing in")
//                    await signIn(message)
//                case .failure(let error):
//                    print("failed to issue tokens, try again")
//                    print(error)
//                    await global.displayError(error)
//                }
//            }
//
//        case .failure(let error):
//            print("siwa failed")
//            print(error)
//            Task {
//                await global.displayError(error)
//            }
//        }
//    }
//}
