//===----------------------------------------------------------------------===//
//
// This source file is part of the lightroom-sdk-swift open source project
//
// Copyright (c) 2020 pokryfka and the lightroom-sdk-swift project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import AsyncHTTPClient
import NIO
import NIOConcurrencyHelpers
import NIOHTTP1
import PureSwiftJSON

public class AdobeIOClient {
    public struct Config {
        let apiKey: String

        public init(apiKey: String) {
            self.apiKey = apiKey
        }
    }

    public struct Request {
        public enum Method: String {
            case GET
        }

        public let method: Method
        public let url: String
    }

    public struct Response {
        internal let statusCode: UInt
        public let bytes: [UInt8]
    }

    public enum ClientError: Error {
        case noAccessToken
        case requestError(Error)
        case executeError(Error)
        case noBody
        case responseError(code: UInt, description: String, errors: [String: [String]]? = nil)
        case decodingError(Error)
    }

    private let config: Config

    private let httpClient: HTTPClient
    private let jsonDecoder = PSJSONDecoder()

    private let lock = Lock()
    private var _accessToken: String?
    public var accessToken: String? {
        get { lock.withLock { _accessToken } }
        set { lock.withLockVoid { _accessToken = newValue } }
    }

    private var eventLoop: NIO.EventLoop {
        httpClient.eventLoopGroup.next()
    }

    public init(config: Config) {
        self.config = config
        // TODO: allow to reuse client or event loop group
        httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
    }

    public convenience init(apiKey: String) {
        self.init(config: .init(apiKey: apiKey))
    }

    public func syncShutdown() throws {
        try httpClient.syncShutdown()
    }

    public func execute(_ request: Request, fixJSONContent: Bool = true) -> NIO.EventLoopFuture<Response> {
        guard
            let accessToken = accessToken
        else {
            return eventLoop.makeFailedFuture(ClientError.noAccessToken)
        }

        let headers = HTTPHeaders([
            ("X-API-Key", config.apiKey),
            ("Authorization", "Bearer \(accessToken)"),
        ])

        let httpRequest: HTTPClient.Request
        do {
            httpRequest = try HTTPClient.Request(url: request.url, method: .init(request.method),
                                                 headers: headers, body: nil)
        } catch {
            return eventLoop.makeFailedFuture(ClientError.requestError(error))
        }

        return httpClient.execute(request: httpRequest)
            .flatMapErrorThrowing { throw ClientError.executeError($0) }
            .flatMapThrowing { try Response($0, fixJSONContent: fixJSONContent) }
            .flatMapThrowing { response in
                guard response.statusCode >= 200, response.statusCode < 300 else {
                    if let errorResponse = try? self.jsonDecoder.decode(ErrorResponse.self, from: response.bytes) {
                        throw ClientError.responseError(code: errorResponse.code,
                                                        description: errorResponse.description,
                                                        errors: errorResponse.errors)
                    } else {
                        throw ClientError.responseError(code: response.statusCode, description: "Unknown")
                    }
                }
                return response
            }
    }

    public func execute<T: Decodable>(_ request: Request, fixJSONContent: Bool = true) -> NIO.EventLoopFuture<T> {
        execute(request, fixJSONContent: fixJSONContent).flatMapThrowing { response in
            do {
                return try self.jsonDecoder.decode(T.self, from: response.bytes)
            } catch {
                throw ClientError.decodingError(error)
            }
        }
    }

    public func execute(_ request: Request, fixJSONContent: Bool = true, callback: @escaping (Result<Response, Error>) -> Void) {
        execute(request, fixJSONContent: fixJSONContent).whenComplete(callback)
    }

    public func execute<T: Decodable>(_ request: Request, fixJSONContent: Bool = true, callback: @escaping (Result<T, Error>) -> Void) {
        execute(request, fixJSONContent: fixJSONContent).whenComplete(callback)
    }
}

extension AdobeIOClient {
    public func get(_ url: String, fixJSONContent: Bool = true) -> NIO.EventLoopFuture<Response> {
        execute(Request(method: .GET, url: url), fixJSONContent: fixJSONContent)
    }

    public func get<T: Decodable>(_ url: String, fixJSONContent: Bool = true) -> NIO.EventLoopFuture<T> {
        execute(Request(method: .GET, url: url), fixJSONContent: fixJSONContent)
    }

    public func get(_ url: String, fixJSONContent: Bool = true, callback: @escaping (Result<Response, Error>) -> Void) {
        execute(Request(method: .GET, url: url), fixJSONContent: fixJSONContent).whenComplete(callback)
    }

    public func get<T: Decodable>(_ url: String, fixJSONContent: Bool = true, callback: @escaping (Result<T, Error>) -> Void) {
        execute(Request(method: .GET, url: url), fixJSONContent: fixJSONContent).whenComplete(callback)
    }
}

internal extension AdobeIOClient {
    struct ErrorResponse: Decodable {
        let code: UInt
        let description: String
        let errors: [String: [String]]?

        enum CodingKeys: String, CodingKey {
            case code
            case description
            case errors
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            // the code is sometimes returned as string
            do {
                code = try container.decode(UInt.self, forKey: .code)
            } catch {
                if let stringCode = try? container.decode(String.self, forKey: .code),
                    let intCode = UInt(stringCode)
                {
                    code = intCode
                } else {
                    throw error
                }
            }
            description = try container.decode(String.self, forKey: .description)
            errors = try container.decodeIfPresent([String: [String]].self, forKey: .errors)
        }
    }
}

private extension NIOHTTP1.HTTPMethod {
    init(_ method: AdobeIOClient.Request.Method) {
        switch method {
        case .GET:
            self = .GET
        }
    }
}

private extension AdobeIOClient.Response {
    init(_ response: HTTPClient.Response, fixJSONContent: Bool = true) throws {
        guard var body = response.body else { throw AdobeIOClient.ClientError.noBody }
        statusCode = response.status.code
        // see https://www.adobe.io/apis/creativecloud/lightroom/docs.html#!usage/calling.md
        if fixJSONContent && response.headers.first(name: "Content-Type") == "application/json" {
            _ = body.readBytes(length: 12)
        }
        bytes = body.readBytes(length: body.readableBytes) ?? [UInt8]()
    }
}
