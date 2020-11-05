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

import NIO

extension AdobeIOClient {
    private func execute(_ operation: Lightroom.API) -> NIO.EventLoopFuture<AdobeIOClient.Response> {
        execute(Request(method: operation.method, url: operation.url))
    }

    private func execute<Response: Decodable>(_ operation: Lightroom.API) -> NIO.EventLoopFuture<Response> {
        execute(Request(method: operation.method, url: operation.url))
    }

    public func health() -> NIO.EventLoopFuture<Lightroom.Health> {
        execute(.health)
    }

    public func account() -> NIO.EventLoopFuture<Lightroom.Account> {
        execute(.account)
    }

    public func catalog() -> NIO.EventLoopFuture<Lightroom.Catalog> {
        execute(.catalog)
    }

    public func assets(catalogId: Lightroom.Catalog.UUID) -> NIO.EventLoopFuture<Lightroom.Resources<Lightroom.AssetPayload>> {
        execute(.assets(catalogId: catalogId))
    }

    public func asset(catalogId: Lightroom.Catalog.UUID, assetId: Lightroom.Asset.UUID) -> NIO.EventLoopFuture<Lightroom.Asset> {
        execute(.asset(catalogId: catalogId, assetId: assetId))
    }

    public func assetRendition(catalogId: Lightroom.Catalog.UUID, assetId: Lightroom.Asset.UUID,
                               rentitionType: Lightroom.RenditionType) -> NIO.EventLoopFuture<AdobeIOClient.Response>
    {
        execute(.assetRendition(catalogId: catalogId, assetId: assetId, renditionType: rentitionType))
    }

    public func albums(catalogId: Lightroom.Catalog.UUID,
                       type: Lightroom.AlbumType? = nil, limit: UInt? = nil) -> NIO.EventLoopFuture<Lightroom.Albums>
    {
        execute(.albums(catalogId: catalogId, type: type, limit: limit))
    }

    public func album(catalogId: Lightroom.Catalog.UUID, albumId: Lightroom.Album.UUID) -> NIO.EventLoopFuture<Lightroom.Album> {
        execute(.album(catalogId: catalogId, albumId: albumId))
    }

    public func albumAssets(catalogId: Lightroom.Catalog.UUID, albumId: Lightroom.Album.UUID, limit: UInt? = nil) -> NIO.EventLoopFuture<Lightroom.AlbumAssets> {
        execute(.albumAssets(catalogId: catalogId, albumId: albumId, limit: limit))
    }
}
