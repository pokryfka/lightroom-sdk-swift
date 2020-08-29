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

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#endif

internal func env(_ name: String) -> String? {
    #if canImport(Darwin)
        guard let value = getenv(name) else { return nil }
        return String(cString: value)
    #elseif canImport(Glibc)
        guard let value = getenv(name) else { return nil }
        return String(cString: value)
    #else
        return nil
    #endif
}
