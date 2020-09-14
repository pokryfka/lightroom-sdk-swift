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
    public typealias Asset = Resource<AssetPayload>
    public typealias Assets = Resources<AssetPayload>
    public typealias AssetRef = ResourceRef<AssetPayload>

    public enum RenditionType: String, Decodable {
        case thumbnail2x
        case longEdge640 = "640"
        case longEdge1280 = "1280"
        case longEdge2048 = "2048"
    }

    public struct AssetPayload: Decodable {
        public struct ImportSource: Decodable {
            public let fileName: String
            public let fileSize: FileSize
            public let originalWidth: UInt
            public let originalHeight: UInt
            public let sha256: SHA256
            public let importedOnDevice: String
            public let importedBy: Account.UUID
            public let importTimestamp: UTCDateTime
        }

        public struct Video: Decodable {
            // TODO: impl
        }

        public struct Location: Decodable {
            public let longitude: Float
            public let latitude: Float
            public let altitude: Float?
            public let direction: Float?
            public let reference: String?
            public let state: String?
            public let country: String?
            public let isoCountryCode: String?
        }

        public let captureDate: UTCDateTime
        public let importSource: ImportSource
        public let video: Video?
        public let userCreated: UTCDateTime?
        public let userUpdated: UTCDateTime?
        public let xmp: XMP?
        public let location: Location?
        // TODO: develop
    }
}

extension Lightroom.Asset {
    public var assetLink: Lightroom.Link? {
        links?["self"]
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

extension Lightroom.AssetPayload {
    // see https://www.iptc.org/std/photometadata/specification/IPTC-PhotoMetadata
    public struct XMP: Decodable {
        public struct Exif: Decodable {
            // TODO: impl
        }

        public struct Dc: Decodable {
            public let title: String?
            public let description: String?
            public let subject: [String: Bool]?
        }

        public let exif: Exif?
        public let dc: Dc?

        // TODO: not complete
    }
}

extension Lightroom.AssetPayload {
    public var title: String? { xmp?.dc?.title }
    public var caption: String? { xmp?.dc?.description }
    public var keywords: [String]? { xmp?.dc?.subject?.filter { $0.value }.map(\.key) }
}
