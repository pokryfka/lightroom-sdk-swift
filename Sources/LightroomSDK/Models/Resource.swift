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
    public struct Resource<Payload: Decodable>: Decodable {
        public struct UUID: RawRepresentable, Decodable {
            public let rawValue: String

            public init(rawValue: String) {
                self.rawValue = rawValue
            }
        }

        public struct RevisionID: RawRepresentable, Decodable {
            public let rawValue: String

            public init(rawValue: String) {
                self.rawValue = rawValue
            }
        }

        public fileprivate(set) var base: String?
        public let id: UUID
        public let type: String
        public let subtype: String?
        public let created: UTCDateTime
        public let updated: UTCDateTime
        public let revisionIDs: [RevisionID]?
        public let links: [String: Link]?
        public let asset: AssetRef?
        public let payload: Payload

        enum CodingKeys: String, CodingKey {
            case base
            case id
            case type
            case subtype
            case created
            case updated
            case revisionIDs = "revision_ids"
            case links
            case asset
            case payload
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            base = try container.decodeIfPresent(String.self, forKey: .base)
            id = try container.decode(UUID.self, forKey: .id)
            type = try container.decode(String.self, forKey: .type)
            subtype = try container.decodeIfPresent(String.self, forKey: .subtype)
            created = try container.decode(UTCDateTime.self, forKey: .created)
            updated = try container.decode(UTCDateTime.self, forKey: .updated)
            revisionIDs = try container.decodeIfPresent([RevisionID].self, forKey: .revisionIDs)
            links = try container.decodeIfPresent([String: Link].self, forKey: .links)
            asset = try container.decodeIfPresent(ResourceRef<AssetPayload>.self, forKey: .asset)
            payload = try container.decode(Payload.self, forKey: .payload)
        }
    }

    public struct ResourceRef<Payload: Decodable>: Decodable {
        public let id: Resource<Payload>.UUID
        public let links: [String: Link]?
    }

    public struct Resources<Payload: Decodable>: Decodable {
        public let base: String
        public let resources: [Resource<Payload>]
        // TODO: (optional) errors
        public let links: [String: Link]?

        enum CodingKeys: String, CodingKey {
            case base
            case resources
            case links
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let base = try container.decode(String.self, forKey: .base)
            resources = try container.decode([Resource<Payload>].self, forKey: .resources)
                .map { value in
                    var value = value
                    value.base = base
                    return value
                }
            self.base = base
            links = try container.decodeIfPresent([String: Link].self, forKey: .links)
        }
    }
}

extension Lightroom.Resources {
    var prevLink: Lightroom.Link? {
        links?["prev"]
    }

    var nextLink: Lightroom.Link? {
        links?["next"]
    }

    var prevURL: String? {
        guard let link = prevLink else { return nil }
        return "\(base)\(link.href)"
    }

    var nextURL: String? {
        guard let link = nextLink else { return nil }
        return "\(base)\(link.href)"
    }

    var prevRequest: AdobeIOClient.Request? {
        guard let url = prevURL else { return nil }
        return .init(method: .GET, url: url)
    }

    var nextRequest: AdobeIOClient.Request? {
        guard let url = nextURL else { return nil }
        return .init(method: .GET, url: url)
    }
}
