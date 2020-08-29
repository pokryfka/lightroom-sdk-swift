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
import XCTest

final class ClientTests: XCTestCase {
    func testShutdown() throws {
        let apiKey: String = UUID().uuidString
        let client = AdobeIOClient(apiKey: apiKey)
        XCTAssertNoThrow(try client.syncShutdown())
    }

    func testNoAccessToken() throws {
        let apiKey: String = UUID().uuidString

        let client = AdobeIOClient(apiKey: apiKey)
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
}
