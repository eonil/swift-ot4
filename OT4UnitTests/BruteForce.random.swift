//
//  BruteForce.random.swift
//  OT4ViewUnitTests
//
//  Created by Henry on 2019/05/19.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation
@testable import OT4

extension Dictionary where Key: Comparable {
    func reproducibleRandom(_ r: inout ReproduciblePRNG) -> (Key,Value)? {
        // Hash-table is not stabley ordered.
        // Simple random query is NOT reproducible.
        // Sort them and select random one in it.
        guard count > 0 else { return nil }
        let ks = keys.sorted()
        let i = r.next() % ks.count
        let k = ks[i]
        let v = self[k]!
        return (k,v)
    }
}

extension HAMT where Key: Comparable {
    func reproducibleRandom(_ r: inout ReproduciblePRNG) -> (Key,Value)? {
        // Hash-table is not stabley ordered.
        // Simple random query is NOT reproducible.
        // Sort them and select random one in it.
        guard count > 0 else { return nil }
        let ks = keys.sorted()
        let i = r.next() % ks.count
        let k = ks[i]
        let v = self[k]!
        return (k,v)
    }
}

extension OT4SnapshotProtocol where Identity: Comparable {
    func reproducibleRandom(_ r: inout ReproduciblePRNG) -> (Identity,State)? {
        // Hash-table is not stabley ordered.
        // Simple random query is NOT reproducible.
        // Sort them and select random one in it.
        guard count > 0 else { return nil }
        let ks = identities.sorted()
        let i = r.next() % ks.count
        let k = ks[i]
        let v = self.state(of: k)
        return (k,v)
    }
}
