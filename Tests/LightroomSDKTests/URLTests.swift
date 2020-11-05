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

final class URLTests: XCTestCase {
    private typealias API = Lightroom.API

    func testHealthURL() {
        XCTAssertEqual(API.health.url, "https://lr.adobe.io/v2/health")
    }

    func testAccountURL() {
        XCTAssertEqual(API.account.url, "https://lr.adobe.io/v2/account")
    }

    func testCatalogURL() {
        XCTAssertEqual(API.catalog.url, "https://lr.adobe.io/v2/catalog")
    }

    func testAssetsURL() {
        let catalogId = Lightroom.Catalog.UUID(rawValue: UUID().uuidString)
        XCTAssertEqual(API.assets(catalogId: catalogId).url,
                       "https://lr.adobe.io/v2/catalogs/\(catalogId)/assets")
    }

    func testAssetURL() {
        let catalogId = Lightroom.Catalog.UUID(rawValue: UUID().uuidString)
        let assetId = Lightroom.Asset.UUID(rawValue: UUID().uuidString)
        XCTAssertEqual(API.asset(catalogId: catalogId, assetId: assetId).url,
                       "https://lr.adobe.io/v2/catalogs/\(catalogId)/assets/\(assetId)")
    }

    func testAssetRenditionURL() {
        let catalogId = Lightroom.Catalog.UUID(rawValue: UUID().uuidString)
        let assetId = Lightroom.Asset.UUID(rawValue: UUID().uuidString)
        let baseURL = "https://lr.adobe.io/v2/catalogs/\(catalogId)/assets/\(assetId)"
        let renditionTypes: [Lightroom.RenditionType] = [
            .thumbnail2x, .longEdge640, .longEdge1280, .longEdge2048,
        ]
        for renditionType in renditionTypes {
            let operation = API.assetRendition(catalogId: catalogId, assetId: assetId,
                                               renditionType: renditionType)
            XCTAssertEqual(operation.url, "\(baseURL)/renditions/\(renditionType)")
        }
    }

    func testAlbumsDefaultURL() {
        let catalogId = Lightroom.Catalog.UUID(rawValue: UUID().uuidString)
        XCTAssertEqual(API.albums(catalogId: catalogId, type: nil, limit: nil).url,
                       "https://lr.adobe.io/v2/catalogs/\(catalogId)/albums")
    }

    func testAlbumsWithLimitURL() {
        let catalogId = Lightroom.Catalog.UUID(rawValue: UUID().uuidString)
        let limit = UInt.random(in: 1 ... 100)
        XCTAssertEqual(API.albums(catalogId: catalogId, type: nil, limit: limit).url,
                       "https://lr.adobe.io/v2/catalogs/\(catalogId)/albums?limit=\(limit)")
    }

    func testAlbumsOfTypeURL() {
        let catalogId = Lightroom.Catalog.UUID(rawValue: UUID().uuidString)
        let albumTypes: [Lightroom.AlbumType] = [.collection, .collectionSet]
        for albumType in albumTypes {
            XCTAssertEqual(API.albums(catalogId: catalogId, type: albumType, limit: nil).url,
                           "https://lr.adobe.io/v2/catalogs/\(catalogId)/albums?subtype=\(albumType)")
        }
    }

    func testAlbumsOfTypeWithLimitURL() throws {
        let catalogId = Lightroom.Catalog.UUID(rawValue: UUID().uuidString)
        let albumTypes: [Lightroom.AlbumType] = [.collection, .collectionSet]
        for albumType in albumTypes {
            let limit = UInt.random(in: 1 ... 100)
            let url = API.albums(catalogId: catalogId, type: albumType, limit: limit).url
            let urlComponents = try XCTUnwrap(URLComponents(string: url))
            XCTAssertEqual(urlComponents.host, "lr.adobe.io")
            XCTAssertEqual(urlComponents.path, "/v2/catalogs/\(catalogId)/albums")
            let queryItems = try XCTUnwrap(urlComponents.queryItems)
            let typeQueryItems = queryItems.filter { $0.name == "subtype" }
            XCTAssertEqual(typeQueryItems.count, 1)
            let typeQuery = try XCTUnwrap(typeQueryItems.first)
            XCTAssertEqual(typeQuery.value, String(describing: albumType))
            let limitQueryItems = queryItems.filter { $0.name == "limit" }
            XCTAssertEqual(limitQueryItems.count, 1)
            let limitQuery = try XCTUnwrap(limitQueryItems.first)
            XCTAssertEqual(limitQuery.value, String(describing: limit))
        }
    }

    func testAlbumURL() {
        let catalogId = Lightroom.Catalog.UUID(rawValue: UUID().uuidString)
        let albumId = Lightroom.Album.UUID(rawValue: UUID().uuidString)
        XCTAssertEqual(API.album(catalogId: catalogId, albumId: albumId).url,
                       "https://lr.adobe.io/v2/catalogs/\(catalogId)/albums/\(albumId)")
    }

    func testAlbumAssetsURL() {
        let catalogId = Lightroom.Catalog.UUID(rawValue: UUID().uuidString)
        let albumId = Lightroom.Album.UUID(rawValue: UUID().uuidString)
        XCTAssertEqual(API.albumAssets(catalogId: catalogId, albumId: albumId, limit: nil).url,
                       "https://lr.adobe.io/v2/catalogs/\(catalogId)/albums/\(albumId)/assets")
    }

    func testAlbumAssetsWithLimitURL() {
        let catalogId = Lightroom.Catalog.UUID(rawValue: UUID().uuidString)
        let albumId = Lightroom.Album.UUID(rawValue: UUID().uuidString)
        let limit: UInt = 42
        XCTAssertEqual(API.albumAssets(catalogId: catalogId, albumId: albumId, limit: limit).url,
                       "https://lr.adobe.io/v2/catalogs/\(catalogId)/albums/\(albumId)/assets?limit=\(limit)")
    }
}
