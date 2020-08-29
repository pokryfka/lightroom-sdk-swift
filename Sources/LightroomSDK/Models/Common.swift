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
    /// datetime in ISO-8601 format (e.g. 2016-01-15T16:18:00-05:00) with both date and time required, including seconds, but timezone optional.
    /// Also flexible on allowing some nonstandard timezone formats like 2016-01-15T12:10:32+0000 or 2016-01-15T12:10:32-05.
    public struct ISO8601DateTime: RawRepresentable, Decodable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }

    /// datetime in RFC-3339 format (subset of ISO-8601) requiring a UTC time ending with Z(so -00:00 or +00-00 suffix NOT allowed).
    /// The datetime must have date and time, including seconds, e.g. 2016-01-15T09:23:34Z.
    public struct UTCDateTime: RawRepresentable, Decodable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }

    public struct Link: Decodable {
        let href: String
        let templated: Bool?
    }

    public struct FileSize: RawRepresentable, Decodable {
        public let rawValue: UInt64

        public init(rawValue: UInt64) {
            self.rawValue = rawValue
        }
    }

    public struct SHA256: RawRepresentable, Decodable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}
