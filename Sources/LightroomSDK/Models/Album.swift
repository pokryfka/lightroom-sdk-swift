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
    public typealias AlbumAssets = Resources<AlbumAssetPayload>

    public struct AlbumPayload: Decodable {
        public let userCreated: UTCDateTime
        public let userUpdated: UTCDateTime
        public let name: String
        public let cover: AssetRef?
        public let parent: AlbumRef?
        // TODO: publishedInfo
    }

    public struct AlbumAssetPayload: Decodable {
        public let userCreated: UTCDateTime?
        public let userUpdated: UTCDateTime?
    }
}
