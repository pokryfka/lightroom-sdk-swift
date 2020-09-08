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

final class APITests: XCTestCase {
    let testApiKey: String? = env("ADOBEIO_API_KEY")
    let testAccessToken: String? = env("ADOBEIO_ACCESS_TOKEN")
    let timeout: TimeInterval = 1

    func addAttachemnt(string: String, name: String) {
        #if os(macOS)
            let attachment = XCTAttachment(string: string)
            attachment.name = name
            attachment.lifetime = .keepAlways
            super.add(attachment)
        #endif
    }

    func addAttachemnt(image: [UInt8], name: String) {
        #if os(macOS)
            guard let image = NSImage(data: Data(image)) else {
                XCTFail("Invalid image")
                return
            }
            let attachment = XCTAttachment(image: image)
            attachment.name = name
            attachment.lifetime = .keepAlways
            add(attachment)
        #endif
    }

    func testInvalidApiKey() throws {
        try XCTSkipIf(testAccessToken == nil)
        let apiKey = UUID().uuidString
        let client = AdobeIOClient(apiKey: apiKey)
        defer {
            XCTAssertNoThrow(try client.syncShutdown())
        }
        client.accessToken = testAccessToken

        let exp = expectation(description: "Response")

        client.execute(.init(.account)) { response in
            switch response {
            case let .failure(error):
                if case let AdobeIOClient.ClientError.responseError(code, description, _) = error {
                    XCTAssertEqual(code, 403_003)
                    print("Description: \(description)")
                } else {
                    XCTFail("Unexpected error: \(error)")
                }
            case .success:
                XCTFail("Unexpected success")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: timeout)
    }

    func testInvalidAccessToken() throws {
        try XCTSkipIf(testApiKey == nil)
        let apiKey = try XCTUnwrap(testApiKey)
        let client = AdobeIOClient(apiKey: apiKey)
        defer {
            XCTAssertNoThrow(try client.syncShutdown())
        }
        client.accessToken = UUID().uuidString

        let exp = expectation(description: "Response")

        client.execute(.init(.account)) { response in
            switch response {
            case let .failure(error):
                if case let AdobeIOClient.ClientError.responseError(code, description, _) = error {
                    XCTAssertEqual(code, 4002)
                    print("Description: \(description)")
                } else {
                    XCTFail("Unexpected error: \(error)")
                }
            case .success:
                XCTFail("Unexpected success")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: timeout)
    }

    func testAPI<Response: Decodable>(_ execute: (AdobeIOClient, @escaping (Result<Response, Error>) -> Void) -> Void) throws {
        try XCTSkipIf(testApiKey == nil || testAccessToken == nil)
        let apiKey = try XCTUnwrap(testApiKey)
        let client = AdobeIOClient(apiKey: apiKey)
        defer {
            XCTAssertNoThrow(try client.syncShutdown())
        }
        client.accessToken = testAccessToken

        let exp = expectation(description: "Response")

        execute(client) { result in
            switch result {
            case let .failure(error):
                XCTFail("Failed with error: \(error)")
            case let .success(result):
                print("Result: \(result)")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: timeout)
    }

    func testHealthAPI() throws {
        try testAPI { client, callback in
            client.health(callback)
        }
    }

    func testAccountAPI() throws {
        try testAPI { client, callback in
            client.account(callback)
        }
    }

    func testCatalogAPI() throws {
        try testAPI { client, callback in
            client.catalog(callback)
        }
    }

    func testGettingAssets() throws {
        try XCTSkipIf(testApiKey == nil || testAccessToken == nil)
        let apiKey = try XCTUnwrap(testApiKey)
        let client = AdobeIOClient(apiKey: apiKey)
        defer {
            XCTAssertNoThrow(try client.syncShutdown())
        }
        client.accessToken = testAccessToken

        try client.catalog()
            .flatMap { catalog in
                client.assets(catalogId: catalog.id)
            }
            .flatMap { response -> NIO.EventLoopFuture<Lightroom.Assets> in
                print("First page resources count: \(response.resources.count)")
                XCTAssertNil(response.prevURL)
                // assume there is next page
                let nextURL = try! XCTUnwrap(response.nextURL)
                print("nextURL: \(nextURL)")
                return client.get(nextURL)
            }
            .map { response in
                print("Second page resources.count: \(response.resources.count)")
                let prevURL = try! XCTUnwrap(response.prevURL)
                print("prevURL: \(prevURL)")
                if let url = response.nextURL {
                    print("nextURL: \(url)")
                }
                return
            }
            .wait()
    }

    func testDownloadingAssetRendition() throws {
        try XCTSkipIf(testApiKey == nil || testAccessToken == nil)
        let apiKey = try XCTUnwrap(testApiKey)
        let client = AdobeIOClient(apiKey: apiKey)
        defer {
            XCTAssertNoThrow(try client.syncShutdown())
        }
        client.accessToken = testAccessToken

        try client.catalog()
            .flatMap { catalog in
                client.assets(catalogId: catalog.id)
                    .map { (catalog.id, $0) }
            }
            .flatMapThrowing { ($0.0, try XCTUnwrap($0.1.resources.first)) }
            .flatMap { (catalogId, asset) -> NIO.EventLoopFuture<AdobeIOClient.Response> in
//                client.assetRendition(catalogId: catalogId, assetId: asset.id, rentitionType: .thumbnail2x)
                let request = AdobeIOClient.Request(.assetRendition(catalogId: catalogId,
                                                                    assetId: asset.id,
                                                                    renditionType: .thumbnail2x))
                self.addAttachemnt(string: request.url, name: "URL")
                return client.execute(request)
            }
            .always { result in
                switch result {
                case let .failure(error):
                    XCTFail("Failed with error: \(error)")
                case let .success(result):
                    self.addAttachemnt(image: result.bytes, name: "Thumbnail")
                }
            }
            .map { _ in }
            .wait()
    }

    func testGettingAlbums() throws {
        try XCTSkipIf(testApiKey == nil || testAccessToken == nil)
        let apiKey = try XCTUnwrap(testApiKey)
        let client = AdobeIOClient(apiKey: apiKey)
        defer {
            XCTAssertNoThrow(try client.syncShutdown())
        }
        client.accessToken = testAccessToken

        let result = try client.catalog()
            .flatMap { catalog in
                client.albums(catalogId: catalog.id)
            }
            .wait()

        XCTAssertFalse(result.resources.isEmpty)
    }

    func testGettingCollectionAlbums() throws {
        try XCTSkipIf(testApiKey == nil || testAccessToken == nil)
        let apiKey = try XCTUnwrap(testApiKey)
        let client = AdobeIOClient(apiKey: apiKey)
        defer {
            XCTAssertNoThrow(try client.syncShutdown())
        }
        client.accessToken = testAccessToken

        let result = try client.catalog()
            .flatMap { catalog in
                client.albums(catalogId: catalog.id, type: .collection, limit: 5)
            }
            .wait()

        XCTAssertEqual(result.resources.count, 5)
        XCTAssertEqual(result.resources.filter { $0.subtype == Lightroom.AlbumType.collection.rawValue }.count, 5)
    }

    func testGettingAlbumAssets() throws {
        try XCTSkipIf(testApiKey == nil || testAccessToken == nil)
        let apiKey = try XCTUnwrap(testApiKey)
        let client = AdobeIOClient(apiKey: apiKey)
        defer {
            XCTAssertNoThrow(try client.syncShutdown())
        }
        client.accessToken = testAccessToken

        _ = try client.catalog()
            .flatMap { catalog in
                client.albums(catalogId: catalog.id)
                    .flatMapThrowing { (catalog.id, try XCTUnwrap($0.resources.first)) }
            }
//            .flatMap { catalogId, album in
//                client.albumAssets(catalogId: catalogId, albumId: album.id)
//            }
            .wait()

        // TODO: not all albums have assets, update when query is available
    }
}
