//
//  OT4SnapshotProtocol.swift
//  OT4
//
//  Created by Henry on 2019/05/25.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation

public protocol OT4SnapshotProtocol {
    associatedtype Identity: Hashable
    associatedtype State
    /// Stacked identities through root to the node.
    associatedtype Path: RandomAccessCollection where Path.Element == Identity
    ///
    /// - Note:
    ///     OT4 calls `firstIndex(of:)` method to find index of an identity
    ///     in child collection. Though generic algorithm is `O(n)`, you can
    ///     provide your own implementation for better performance if possible.
    ///     As this method will be called very frequently, performance gain
    ///     can be great.
    ///     This overriding can be critical for some apps. For examples,
    ///     if your children is strictly append-only, you can use indices
    ///     as a part of key, and in that case, the function can be implemented
    ///     in `O(1)` time.
    ///
    associatedtype ChildCollection: RandomAccessCollection where
        ChildCollection.Element == Identity,
        ChildCollection.Index == Int

    var isEmpty: Bool { get }
    var count: Int { get }
    func contains(_ id: Identity) -> Bool
    func state(of id: Identity) -> State
    func parent(of id: Identity) -> Identity?
    func children(of id: Identity) -> ChildCollection
    /// - Complexity:
    ///     Must be <= O(depth * max degree)
    func path(of id: Identity) -> Path
    /// - Complexity:
    ///     Must be <= O(depth * log(max degree))
    /// - Note:
    ///     Crashes if there's no node in this snapshot.
    func identity(at idxp: IndexPath) -> Identity
    func branchability(of id: Identity) -> OT4Branchability
}
extension OT4SnapshotProtocol {
    ///
    /// Gets index-path for an identity.
    ///
    /// - Complexity:
    ///     Default implementation uses generic algorithm
    ///     and takes `<= O(depth * max degree)` time at
    ///     worst.
    ///     Override this if you can provide better performance.
    ///
    func index(of id: Identity) -> IndexPath {
        guard let pid = parent(of: id) else { return [] }
        let pidxp = index(of: pid)
        let ids = children(of: pid)
        let i = ids.firstIndex(of: id)!
        return pidxp.appending(i)
    }
    //    /// - Complexity:   O(1)
    //    func identity(at path: Path) -> Identity {
    //        precondition(!path.isEmpty, "Empty path is not acceptable.")
    //        let id = path.last!
    //        return id
    //    }
}
extension OT4SnapshotProtocol where Path: ExpressibleByArrayLiteral & MutableCollection {
    public func path(of id: Identity) -> Path {
        guard let pid = parent(of: id) else { return [id] as! Path }
        var p = path(of: pid)
        p[p.endIndex] = id
        return p
    }
}


