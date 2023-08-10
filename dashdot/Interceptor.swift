//
//  Client.swift
//  dashdot
//
//  Created by Arden Sinclair on 2023-05-04.
//

import Foundation
import Connect

final class AuthInterceptor: Interceptor {
    static let shared = AuthInterceptor()

    private init() {}
    
    private func addHeadersToRequest(req: HTTPRequest) -> HTTPRequest {
        var headers = req.headers
        if let accessToken = SessionManager.shared.session?.accessToken {
            headers["Authorization"] = ["Bearer \(accessToken)"]
        }
        return HTTPRequest(
            url: req.url,
            contentType: req.contentType,
            headers: headers,
            message: req.message,
            trailers: req.trailers
        )
    }

    func unaryFunction() -> UnaryFunction {
        UnaryFunction(requestFunction: addHeadersToRequest, responseFunction: { $0 })
    }

    func streamFunction() -> StreamFunction {
        StreamFunction(requestFunction: addHeadersToRequest, requestDataFunction: { $0 }, streamResultFunction: { $0 })
    }
}
