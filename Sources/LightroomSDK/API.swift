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

public enum Lightroom {}

extension Lightroom {
    // see https://www.adobe.io/apis/creativecloud/lightroom/apidocs.html
    public enum API {
        internal static let baseURL = "https://lr.adobe.io/v2/"

        /// Lightroom Services health check.
        case health

        /// Retrieve the user account metadata.
        case account

        /// Retrieve the user catalog metadata.
        case catalog

        /// Retrieve a list of existing assets that caller owns.
        case assets(catalogId: Catalog.UUID)

        /// Get a catalog asset.
        case asset(catalogId: Catalog.UUID, assetId: Asset.UUID)

        /// Get latest asset rendition.
        case assetRendition(catalogId: Catalog.UUID, assetId: Asset.UUID, renditionType: RenditionType)

        /// Retrieve albums.
        case albums(catalogId: Catalog.UUID)

        /// Get album.
        case album(catalogId: Catalog.UUID, albumId: Album.UUID)

        /// List assets of an album.
        case albumAssets(catalogId: Catalog.UUID, albumId: Album.UUID)

        internal var method: AdobeIOClient.Request.Method {
            switch self {
            default:
                return .GET
            }
        }

        internal var path: String {
            switch self {
            case .health:
                return "health"
            case .account:
                return "account"
            case .catalog:
                return "catalog"
            case let .assets(catalogId):
                return "catalogs/\(catalogId.rawValue)/assets"
            case let .asset(catalogId, assetId):
                return "catalogs/\(catalogId.rawValue)/assets/\(assetId.rawValue)"
            case let .assetRendition(catalogId, assetId, renditionType):
                return "catalogs/\(catalogId.rawValue)/assets/\(assetId.rawValue)/renditions/\(renditionType.rawValue)"
            case let .albums(catalogId):
                return "catalogs/\(catalogId.rawValue)/albums"
            case let .album(catalogId, albumId):
                return "catalogs/\(catalogId.rawValue)/albums/\(albumId.rawValue)"
            case let .albumAssets(catalogId, albumId):
                return "catalogs/\(catalogId.rawValue)/albums/\(albumId.rawValue)/assets)"
            }
        }

        var url: String {
            "\(Self.baseURL)\(path)"
        }
    }
}

public extension AdobeIOClient.Request {
    init(_ operation: Lightroom.API) {
        self.init(method: operation.method, url: operation.url)
    }
}
