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

@testable import LightroomSDK
import NIO
import XCTest

final class ClientTests: XCTestCase {
    func testShutdown() throws {
        let client = AdobeIOClient(apiKey: UUID().uuidString)
        XCTAssertNoThrow(try client.syncShutdown())
    }

    func testNoAccessToken() throws {
        let client = AdobeIOClient(apiKey: UUID().uuidString)
        defer {
            XCTAssertNoThrow(try client.syncShutdown())
        }

        let exp = expectation(description: "Response")

        client.account { result in
            switch result {
            case let .failure(error):
                if case AdobeIOClient.ClientError.noAccessToken = error {
                    // ok
                } else {
                    XCTFail("Unexpected error: \(error)")
                }
            case let .success(result):
                XCTFail("Unexpected success: \(result)")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    func testGetingJSON() throws {
        let client = AdobeIOClient(apiKey: UUID().uuidString)
        client.accessToken = UUID().uuidString
        defer {
            XCTAssertNoThrow(try client.syncShutdown())
        }

        struct HTTPBinResponse: Decodable {
            let args: [String: String]
            let headers: [String: String]
            let origin: String
            let url: String
        }

        let url = "https://httpbin.org/get?limit=1"
        try client.get(url, fixJSONContent: false)
            .flatMapThrowing { (response: HTTPBinResponse) in
                XCTAssertEqual(response.url, url)
                XCTAssertEqual(response.args["limit"], "1")
            }
            .map { _ in }
            .wait()
    }

    func testGetingImage() throws {
        let client = AdobeIOClient(apiKey: UUID().uuidString)
        client.accessToken = UUID().uuidString
        defer {
            XCTAssertNoThrow(try client.syncShutdown())
        }

        let url = "https://httpbin.org/image/jpeg"
        try client.get(url)
            .flatMapThrowing { response in
                #if os(macOS)
                    _ = try XCTUnwrap(NSImage(data: Data(response.bytes)))
                #endif
            }
            .map { _ in }
            .wait()
    }
}
