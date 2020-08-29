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

extension AdobeIOClient {
    private func execute(_ operation: Lightroom.API,
                         callback: @escaping (Result<AdobeIOClient.Response, Error>) -> Void)
    {
        execute(Request(operation), callback: callback)
    }

    private func execute<Response: Decodable>(_ operation: Lightroom.API,
                                              callback: @escaping (Result<Response, Error>) -> Void)
    {
        execute(Request(operation), callback: callback)
    }

    public func health(_ callback: @escaping (Result<Lightroom.Health, Error>) -> Void) {
        execute(.health, callback: callback)
    }

    public func account(_ callback: @escaping (Result<Lightroom.Account, Error>) -> Void) {
        execute(.account, callback: callback)
    }

    public func catalog(_ callback: @escaping (Result<Lightroom.Catalog, Error>) -> Void) {
        execute(.catalog, callback: callback)
    }

    public func assets(catalogId: Lightroom.Catalog.UUID,
                       callback: @escaping (Result<Lightroom.Assets, Error>) -> Void)
    {
        execute(.assets(catalogId: catalogId), callback: callback)
    }

    public func asset(catalogId: Lightroom.Catalog.UUID, assetId: Lightroom.Asset.UUID,
                      callback: @escaping (Result<Lightroom.Asset, Error>) -> Void)
    {
        execute(.asset(catalogId: catalogId, assetId: assetId), callback: callback)
    }

    public func assetRendition(catalogId: Lightroom.Catalog.UUID, assetId: Lightroom.Asset.UUID,
                               rentitionType: Lightroom.RenditionType,
                               callback: @escaping (Result<AdobeIOClient.Response, Error>) -> Void)
    {
        execute(.assetRendition(catalogId: catalogId, assetId: assetId, renditionType: rentitionType),
                callback: callback)
    }

    public func assetRenditionURL(catalogId: Lightroom.Catalog.UUID, assetId: Lightroom.Asset.UUID,
                                  rentitionType: Lightroom.RenditionType) -> AdobeIOClient.Request
    {
        .init(.assetRendition(catalogId: catalogId, assetId: assetId, renditionType: rentitionType))
    }

    public func albums(catalogId: Lightroom.Catalog.UUID,
                       callback: @escaping (Result<Lightroom.Albums, Error>) -> Void)
    {
        execute(.albums(catalogId: catalogId), callback: callback)
    }

    public func album(catalogId: Lightroom.Catalog.UUID, albumId: Lightroom.Album.UUID,
                      callback: @escaping (Result<Lightroom.Album, Error>) -> Void)
    {
        execute(.album(catalogId: catalogId, albumId: albumId), callback: callback)
    }

    public func albumAssets(catalogId: Lightroom.Catalog.UUID, albumId: Lightroom.Album.UUID,
                            callback: @escaping (Result<Lightroom.AlbumAssets, Error>) -> Void)
    {
        execute(.albumAssets(catalogId: catalogId, albumId: albumId), callback: callback)
    }
}
