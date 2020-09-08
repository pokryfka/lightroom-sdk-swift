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
import PureSwiftJSON
import XCTest

final class DecodingTests: XCTestCase {
    private let jsonDecoder = PSJSONDecoder()

    private func loadResource(_ name: String, ofType type: String = "json") throws -> [UInt8] {
        // see https://forums.swift.org/t/draft-proposal-package-resources/29941
        let cwd = URL(fileURLWithPath: #file).deletingLastPathComponent()
        let resourceURL = cwd.appendingPathComponent("Responses")
            .appendingPathComponent(name)
            .appendingPathExtension(type)
        let data = try Data(contentsOf: resourceURL)
        return [UInt8](data)
    }

    // MARK: - Examples

    func testDecodingHealthResponse() throws {
        let result = try jsonDecoder.decode(Lightroom.Health.self, from: try loadResource("Health"))
        XCTAssertEqual(result.version, "string")
    }

    func testDecodingAccountResponse() throws {
        let result = try jsonDecoder.decode(Lightroom.Account.self, from: try loadResource("Account"))
        XCTAssertEqual(result.base, "https://lr.adobe.io/")
        XCTAssertEqual(result.id.rawValue, "96e656e3812b4c2fb670fa74b6a7ad74")
        XCTAssertEqual(result.type, "account")
        // TODO: impl
    }

    func testDecodingCatalogResponse() throws {
        let result = try jsonDecoder.decode(Lightroom.Catalog.self, from: try loadResource("Catalog"))
        XCTAssertEqual(result.base, "https://lr.adobe.io/v2/")
        XCTAssertEqual(result.id.rawValue, "bf7337d9355c41b7875c9392f918362a")
        XCTAssertEqual(result.type, "catalog")
        // TODO: impl
    }

    func testDecodingAssetsResponse() throws {
        let result = try jsonDecoder.decode(Lightroom.Assets.self, from: try loadResource("Assets"))
        XCTAssertEqual(result.base, "<base_url>")
        XCTAssertGreaterThan(result.resources.count, 0)
        XCTAssertEqual(result.prevURL, "<base_url>albums/<album_id>/assets?captured_after=<first_captured_date>")
        XCTAssertEqual(result.nextURL, "<base_url>albums/<album_id>/assets?captured_before=<last_captured_date>")
        let asset = try XCTUnwrap(result.resources.first)
        XCTAssertEqual(asset.id.rawValue, "<asset_id>")
    }

    func testDecodingAssetsWithErrorsResponse() throws {
        let result = try jsonDecoder.decode(Lightroom.Assets.self, from: try loadResource("AssetsWithErrors"))
        XCTAssertEqual(result.base, "<base_url>")
        XCTAssertGreaterThan(result.resources.count, 0)
        // TODO: check errors
        let asset = try XCTUnwrap(result.resources.first)
        XCTAssertEqual(asset.id.rawValue, "<asset_id>")
    }

    func testDecodingAssetResponse() throws {
        let result = try jsonDecoder.decode(Lightroom.Asset.self, from: try loadResource("Asset"))
        XCTAssertEqual(result.id.rawValue, "<asset_id>")
        XCTAssertEqual(result.type, "asset")
        XCTAssertEqual(result.subtype, "image")
        XCTAssertEqual(result.created.rawValue, "<created_date>")
        XCTAssertEqual(result.updated.rawValue, "<updated_date>")
        XCTAssertEqual(result.revisionIDs?.map(\.rawValue), ["<revision_id1>", "<revision_id2>", "<revision_id3>"])
        XCTAssertEqual(result.assetURL, "<base_url>assets/<asset_id>")
        XCTAssertEqual(result.assetRenditionURL(.longEdge1280), "<base_url>assets/<asset_id>/renditions/1280")
        XCTAssertEqual(result.payload.captureDate.rawValue, "<image_capture_date>")
        XCTAssertEqual(result.payload.importSource.fileName, "<file_name>")
        XCTAssertEqual(result.payload.importSource.fileSize.rawValue, 11)
        XCTAssertEqual(result.payload.importSource.originalWidth, 12)
        XCTAssertEqual(result.payload.importSource.originalHeight, 13)
        XCTAssertEqual(result.payload.importSource.sha256.rawValue, "<image_sha256>")
        XCTAssertEqual(result.payload.importSource.importedOnDevice, "<import_device_name>")
        XCTAssertEqual(result.payload.importSource.importedBy.rawValue, "<import_account_id>")
        XCTAssertEqual(result.payload.importSource.importTimestamp.rawValue, "<import_time>")
    }

    func testDecodingAlbumsResponse() throws {
        let result = try jsonDecoder.decode(Lightroom.Albums.self, from: try loadResource("Albums"))
        XCTAssertEqual(result.base, "string")
        XCTAssertEqual(result.resources.count, 1)
        let album = try XCTUnwrap(result.resources.first)
        XCTAssertNotNil(album.base)
        XCTAssertEqual(album.id.rawValue, "string")
        XCTAssertEqual(album.type, "album")
        XCTAssertEqual(album.created.rawValue, "string")
        XCTAssertEqual(album.updated.rawValue, "string")
        XCTAssertEqual(album.payload.userCreated.rawValue, "string")
        XCTAssertEqual(album.payload.userUpdated.rawValue, "string")
        XCTAssertEqual(album.payload.name, "string")
        XCTAssertEqual(album.payload.cover?.id.rawValue, "string")
        XCTAssertEqual(album.payload.parent?.id.rawValue, "string")
    }

    func testDecodingAlbumAssetsResponse() throws {
        let result = try jsonDecoder.decode(Lightroom.AlbumAssets.self, from: try loadResource("AlbumAssets"))
        XCTAssertEqual(result.base, "<base_url>")
        // we dont parse "album"
        XCTAssertEqual(result.resources.count, 2)
        XCTAssertEqual(result.links?.count, 2)
        XCTAssertEqual(result.prevURL, "<base_url>albums/<album_id>/assets?captured_after=<first_captured_date>")
        XCTAssertEqual(result.nextURL, "<base_url>albums/<album_id>/assets?captured_before=<last_captured_date>")
        let albumAsset = try XCTUnwrap(result.resources.first)
        XCTAssertEqual(albumAsset.id.rawValue, "<album_asset_id>")
        XCTAssertEqual(albumAsset.type, "album_asset")
        XCTAssertEqual(albumAsset.created.rawValue, "<created_date>")
        XCTAssertEqual(albumAsset.updated.rawValue, "<updated_date>")
        XCTAssertEqual(albumAsset.revisionIDs?.map(\.rawValue),
                       ["<album_asset_revision_id1>", "<album_asset_revision_id2>", "<album_asset_revision_id3>"])
        XCTAssertEqual(albumAsset.assetURL, "<base_url>assets/<asset_id>")
        XCTAssertEqual(albumAsset.assetRenditionURL(.longEdge1280), "<base_url>assets/<asset_id>/renditions/1280")
        let asset = try XCTUnwrap(albumAsset.asset)
        XCTAssertEqual(asset.id.rawValue, "<asset_id>")
        // TODO: the actual payload is different then in example
    }

    func testDecodingErrorResponse() throws {
        let result = try jsonDecoder.decode(AdobeIOClient.ErrorResponse.self, from: try loadResource("Error404NotFound"))
        XCTAssertEqual(result.code, 1000)
        XCTAssertEqual(result.description, "Resource not found")
        let errors = try XCTUnwrap(result.errors)
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors["<resource_type>"]?.first, "does not exist")
    }

    // MARK: - For real

    func testDecodingRealAssetResponse() throws {
        let result = try jsonDecoder.decode(Lightroom.Asset.self, from: try loadResource("AssetReal"))
        XCTAssertEqual(result.type, "asset")
        XCTAssertEqual(result.subtype, "image")
        // TODO: impl
    }
}
