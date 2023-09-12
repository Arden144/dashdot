//
//  Singletons.swift
//  dashdot
//
//  Created by Arden Sinclair on 2023-05-27.
//

import Foundation
import Connect

extension ProtocolClient {
    static let shared = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = .infinity
        
        return ProtocolClient(
            httpClient: URLSessionHTTPClient(configuration: configuration),
            config: ProtocolClientConfig(
                host: "http://vps.ardensinclair.com:8080",
                networkProtocol: .grpcWeb,
                codec: ProtoCodec(),
                interceptors: [{ _ in AuthInterceptor.shared }]
            )
        )
    }()
}

extension Api_ChatClient {
    static let shared = Api_ChatClient(client: ProtocolClient.shared)
}

extension Api_AuthClient {
    static let shared = Api_AuthClient(client: ProtocolClient.shared)
}

extension Api_PushClient {
    static let shared = Api_PushClient(client: ProtocolClient.shared)
}
