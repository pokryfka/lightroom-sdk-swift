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

extension Lightroom {
    public typealias Album = Resource<AlbumPayload>
    public typealias Albums = Resources<AlbumPayload>
    public typealias AlbumRef = ResourceRef<AlbumPayload>
    public typealias AlbumAsset = Resource<AlbumAssetPayload>
    public typealias AlbumAssets = Resources<AlbumAssetPayload>

    public enum AlbumType: String, CustomStringConvertible {
        case project
        case projectSet = "project_set"
        case collection
        case collectionSet = "collection_set"

        public var description: String { rawValue }
    }

    public struct AlbumPayload: Decodable {
        public let userCreated: UTCDateTime
        public let userUpdated: UTCDateTime
        public let name: String
        public let cover: AssetRef?
        public let parent: AlbumRef?
    }

    public struct AlbumAssetPayload: Decodable {
        public let userCreated: UTCDateTime?
        public let userUpdated: UTCDateTime?
    }
}

extension Lightroom.AlbumAsset {
    public var assetLink: Lightroom.Link? {
        asset?.links?["self"]
    }

    public var assetURL: String? {
        guard let base = base, let link = assetLink else { return nil }
        return "\(base)\(link.href)"
    }

    public func assetRenditionURL(_ renditionType: Lightroom.RenditionType) -> String? {
        guard let base = base, let link = assetLink else { return nil }
        return "\(base)\(link.href)/renditions/\(renditionType.rawValue)"
    }
}
