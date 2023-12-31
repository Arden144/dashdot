// Code generated by protoc-gen-connect-swift. DO NOT EDIT.
//
// Source: api.proto
//

import Connect
import Foundation
import SwiftProtobuf

public protocol Api_ChatClientInterface {

    @available(iOS 13, *)
    func `sync`(headers: Connect.Headers) -> any Connect.ServerOnlyAsyncStreamInterface<Sync_SyncInfo, Sync_Events>

    @available(iOS 13, *)
    func `sendMsg`(request: Msg_NewMsg, headers: Connect.Headers) async -> ResponseMessage<Msg_MsgSent>
}

/// Concrete implementation of `Api_ChatClientInterface`.
public final class Api_ChatClient: Api_ChatClientInterface {
    private let client: Connect.ProtocolClientInterface

    public init(client: Connect.ProtocolClientInterface) {
        self.client = client
    }

    @available(iOS 13, *)
    public func `sync`(headers: Connect.Headers = [:]) -> any Connect.ServerOnlyAsyncStreamInterface<Sync_SyncInfo, Sync_Events> {
        return self.client.serverOnlyStream(path: "api.Chat/Sync", headers: headers)
    }

    @available(iOS 13, *)
    public func `sendMsg`(request: Msg_NewMsg, headers: Connect.Headers = [:]) async -> ResponseMessage<Msg_MsgSent> {
        return await self.client.unary(path: "api.Chat/SendMsg", request: request, headers: headers)
    }

    public enum Metadata {
        public enum Methods {
            public static let sync = Connect.MethodSpec(name: "Sync", service: "api.Chat", type: .serverStream)
            public static let sendMsg = Connect.MethodSpec(name: "SendMsg", service: "api.Chat", type: .unary)
        }
    }
}

public protocol Api_AuthClientInterface {

    @available(iOS 13, *)
    func `preAuth`(request: Auth_NewSession, headers: Connect.Headers) async -> ResponseMessage<Auth_Session>

    @available(iOS 13, *)
    func `auth`(request: Auth_NewAuth, headers: Connect.Headers) async -> ResponseMessage<Auth_Auth>

    @available(iOS 13, *)
    func `renew`(request: Auth_Renew, headers: Connect.Headers) async -> ResponseMessage<Auth_Auth>
}

/// Concrete implementation of `Api_AuthClientInterface`.
public final class Api_AuthClient: Api_AuthClientInterface {
    private let client: Connect.ProtocolClientInterface

    public init(client: Connect.ProtocolClientInterface) {
        self.client = client
    }

    @available(iOS 13, *)
    public func `preAuth`(request: Auth_NewSession, headers: Connect.Headers = [:]) async -> ResponseMessage<Auth_Session> {
        return await self.client.unary(path: "api.Auth/PreAuth", request: request, headers: headers)
    }

    @available(iOS 13, *)
    public func `auth`(request: Auth_NewAuth, headers: Connect.Headers = [:]) async -> ResponseMessage<Auth_Auth> {
        return await self.client.unary(path: "api.Auth/Auth", request: request, headers: headers)
    }

    @available(iOS 13, *)
    public func `renew`(request: Auth_Renew, headers: Connect.Headers = [:]) async -> ResponseMessage<Auth_Auth> {
        return await self.client.unary(path: "api.Auth/Renew", request: request, headers: headers)
    }

    public enum Metadata {
        public enum Methods {
            public static let preAuth = Connect.MethodSpec(name: "PreAuth", service: "api.Auth", type: .unary)
            public static let auth = Connect.MethodSpec(name: "Auth", service: "api.Auth", type: .unary)
            public static let renew = Connect.MethodSpec(name: "Renew", service: "api.Auth", type: .unary)
        }
    }
}

public protocol Api_PushClientInterface {

    @available(iOS 13, *)
    func `register`(request: Push_Register, headers: Connect.Headers) async -> ResponseMessage<Push_Registered>
}

/// Concrete implementation of `Api_PushClientInterface`.
public final class Api_PushClient: Api_PushClientInterface {
    private let client: Connect.ProtocolClientInterface

    public init(client: Connect.ProtocolClientInterface) {
        self.client = client
    }

    @available(iOS 13, *)
    public func `register`(request: Push_Register, headers: Connect.Headers = [:]) async -> ResponseMessage<Push_Registered> {
        return await self.client.unary(path: "api.Push/Register", request: request, headers: headers)
    }

    public enum Metadata {
        public enum Methods {
            public static let register = Connect.MethodSpec(name: "Register", service: "api.Push", type: .unary)
        }
    }
}
