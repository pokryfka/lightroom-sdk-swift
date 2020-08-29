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
    /// A catalog is the topmost container of resources for a user. Each catalog contains zero or more assets, albums, or other resources.
    public typealias Catalog = Resource<CatalogPayload>

    public struct CatalogPayload: Decodable {
        public enum AssetSortOrder: String, Decodable {
            case captureDateAsc, captureDateDesc
            case importTimestampAsc, importTimestampDesc
            case fileNameAsc, fileNameDesc
            case ratingAsc, ratingDesc, userUpdatedAsc, userUpdatedDesc
        }

        public struct Settings: Decodable {
            // TODO: impl
        }

        public let userCreated: UTCDateTime?
        public let userUpdated: UTCDateTime?
        public let name: String
        public let assetSortOrder: AssetSortOrder?
        public let presets: [String: [String: Bool]]?
        public let profiles: [String: [String: Bool]]?
        public let settings: Settings
        public let revisionIDs: [Catalog.RevisionID]?

        enum CodingKeys: String, CodingKey {
            case userCreated
            case userUpdated
            case name
            case assetSortOrder
            case presets
            case profiles
            case settings
            case revisionIDs = "revision_ids"
        }
    }
}
