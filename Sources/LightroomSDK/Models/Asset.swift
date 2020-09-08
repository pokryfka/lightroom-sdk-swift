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
            let fileName: String
            let fileSize: FileSize
            let originalWidth: UInt
            let originalHeight: UInt
            let sha256: SHA256
            let importedOnDevice: String
            let importedBy: Account.UUID
            let importTimestamp: UTCDateTime
        }

        public struct Video: Decodable {
            // TODO: impl
        }

        public struct Location: Decodable {
            let longitude: Float
            let latitude: Float
            let altitude: Float?
            let direction: Float?
            let reference: String?
            let state: String?
            let country: String?
            let isoCountryCode: String?
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

extension Lightroom.AssetPayload {
    // see https://www.iptc.org/std/photometadata/specification/IPTC-PhotoMetadata
    public struct XMP: Decodable {
        public struct Exif: Decodable {
            // TODO: impl
        }

        public struct Dc: Decodable {
            public let subject: [String: Bool]
        }

        public let exif: Exif?
        public let dc: Dc?

        // TODO: not complete
    }
}

extension Lightroom.AssetPayload {
    public var keywords: [String]? { xmp?.dc?.subject.filter { $0.value }.map(\.key) }
}
