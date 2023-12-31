// Code generated by protoc-gen-connect-swift. DO NOT EDIT.
//
// Source: api.proto
//

import Connect
import ConnectMocks
import Foundation
import SwiftProtobuf

/// Mock implementation of `Api_ChatClientInterface`.
///
/// Production implementations can be substituted with instances of this
/// class, allowing for mocking RPC calls. Behavior can be customized
/// either through the properties on this class or by
/// subclassing the class and overriding its methods.
@available(iOS 13, *)
open class Api_ChatClientMock: Api_ChatClientInterface {
    /// Mocked for async calls to `sync()`.
    public var mockAsyncSync = MockServerOnlyAsyncStream<Sync_SyncInfo, Sync_Events>()
    /// Mocked for async calls to `sendMsg()`.
    public var mockAsyncSendMsg = { (_: Msg_NewMsg) -> ResponseMessage<Msg_MsgSent> in .init(result: .success(.init())) }

    public init() {}

    open func `sync`(headers: Connect.Headers = [:]) -> any Connect.ServerOnlyAsyncStreamInterface<Sync_SyncInfo, Sync_Events> {
        return self.mockAsyncSync
    }

    open func `sendMsg`(request: Msg_NewMsg, headers: Connect.Headers = [:]) async -> ResponseMessage<Msg_MsgSent> {
        return self.mockAsyncSendMsg(request)
    }
}

/// Mock implementation of `Api_AuthClientInterface`.
///
/// Production implementations can be substituted with instances of this
/// class, allowing for mocking RPC calls. Behavior can be customized
/// either through the properties on this class or by
/// subclassing the class and overriding its methods.
@available(iOS 13, *)
open class Api_AuthClientMock: Api_AuthClientInterface {
    /// Mocked for async calls to `preAuth()`.
    public var mockAsyncPreAuth = { (_: Auth_NewSession) -> ResponseMessage<Auth_Session> in .init(result: .success(.init())) }
    /// Mocked for async calls to `auth()`.
    public var mockAsyncAuth = { (_: Auth_NewAuth) -> ResponseMessage<Auth_Auth> in .init(result: .success(.init())) }
    /// Mocked for async calls to `renew()`.
    public var mockAsyncRenew = { (_: Auth_Renew) -> ResponseMessage<Auth_Auth> in .init(result: .success(.init())) }

    public init() {}

    open func `preAuth`(request: Auth_NewSession, headers: Connect.Headers = [:]) async -> ResponseMessage<Auth_Session> {
        return self.mockAsyncPreAuth(request)
    }

    open func `auth`(request: Auth_NewAuth, headers: Connect.Headers = [:]) async -> ResponseMessage<Auth_Auth> {
        return self.mockAsyncAuth(request)
    }

    open func `renew`(request: Auth_Renew, headers: Connect.Headers = [:]) async -> ResponseMessage<Auth_Auth> {
        return self.mockAsyncRenew(request)
    }
}

/// Mock implementation of `Api_PushClientInterface`.
///
/// Production implementations can be substituted with instances of this
/// class, allowing for mocking RPC calls. Behavior can be customized
/// either through the properties on this class or by
/// subclassing the class and overriding its methods.
@available(iOS 13, *)
open class Api_PushClientMock: Api_PushClientInterface {
    /// Mocked for async calls to `register()`.
    public var mockAsyncRegister = { (_: Push_Register) -> ResponseMessage<Push_Registered> in .init(result: .success(.init())) }

    public init() {}

    open func `register`(request: Push_Register, headers: Connect.Headers = [:]) async -> ResponseMessage<Push_Registered> {
        return self.mockAsyncRegister(request)
    }
}
