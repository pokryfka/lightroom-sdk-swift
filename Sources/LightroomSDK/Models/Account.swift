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
    /// An account is associated with each Adobe customer and contains the personal information and subscription status.
    public struct Account: Decodable {
        public struct UUID: RawRepresentable, Decodable, CustomStringConvertible {
            public let rawValue: String
            public var description: String { rawValue }

            public init(rawValue: String) {
                self.rawValue = rawValue
            }
        }

        public struct Entitlement: Decodable {
            public enum Status: String, Decodable {
                case created
                case trial
                case trialExpired
                case subscriber
                case subscriberExpired

                enum CodingKeys: String, CodingKey {
                    case created
                    case trial
                    case trialExpired = "trial_expired"
                    case subscriber
                    case subscriberExpired = "subscriber_expired"
                }
            }

            public struct Trial: Decodable {
                public let start: UTCDateTime
                public let end: UTCDateTime
            }

            public struct Subscription: Decodable {
                public let productId: String
                public let store: String
                public let purchaseDate: UTCDateTime
                public let sao: [String: String]

                enum CodingKeys: String, CodingKey {
                    case productId = "product_id"
                    case store
                    case purchaseDate = "purchase_date"
                    case sao
                }
            }

            public struct Storage: Decodable {
                /// The size in bytes of content this account that count against the storage limit.
                public let used: FileSize
                /// Value of used at which the client applications should start warning the user. Absence indicates no warning should be given.
                public let warn: FileSize
                /// Specifies the storage limit in bytes that should be enforced for this account. It will always be greater than or equal to the display_limit.
                public let limit: FileSize
                /// Specifies the storage limit in bytes that is displayed to the user for this account.
                public let displayLimit: FileSize

                enum CodingKeys: String, CodingKey {
                    case used
                    case warn
                    case limit
                    case displayLimit = "display_limit"
                }
            }

            public let status: Status
            public let trial: Trial?
            public let subscription: Subscription?
            public let storage: Storage?
            public let deletionDate: String?

            enum CodingKeys: String, CodingKey {
                case status
                case trial
                case subscription = "current_subs"
                case storage
                case deletionDate = "deletion_date"
            }
        }

        public let base: String
        public let id: UUID
        public let created: UTCDateTime
        public let updated: UTCDateTime
        public let type: String
        public let email: String
        public let fullName: String
        public let firstName: String
        public let lastName: String
        // TODO: wcd_guid?
        public let country: String
        // TODO: config, Model not defined
        public let entitlement: Entitlement

        enum CodingKeys: String, CodingKey {
            case base
            case id
            case created
            case updated
            case type
            case email
            case fullName = "full_name"
            case firstName = "first_name"
            case lastName = "last_name"
            case country
            case entitlement
        }
    }
}
