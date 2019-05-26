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
    /// Stacked identities from root to a node.
    associatedtype Path: RandomAccessCollection
        where
        Path.Element == Identity
    associatedtype IdentitySequence: Sequence
        where
        IdentitySequence.Element == Identity
    associatedtype ChildCollection:
        RandomAccessCollection
        where
        ChildCollection.Element == Identity,
        ChildCollection.Index == Int

    /// Whether this there's no node in this snapshot.
    /// - Complexity: Must be O(1).
    var isEmpty: Bool { get }

    /// Total number of nodes in this snapshot.
    /// - Complexity: Must be O(1).
    var count: Int { get }

    var identities: IdentitySequence { get }

    /// Whether this snapshot contains a node for an identity.
    /// - Complexity: Must be <= O(log n)
    func contains(_ id: Identity) -> Bool

    /// Gets state of node for an identity.
    /// "state" means arbitrary data that can be stored
    /// for an identity.
    /// - Complexity: Must be <= O(log n)
    func state(of id: Identity) -> State

    /// Gets identities of parent node of node designated by identity.
    /// - Complexity: Must be <= O(log n)
    func parent(of id: Identity) -> Identity?

    /// Gets identities of child nodes of node designated by identity.
    /// - Complexity: Must be <= O(log n)
    func children(of id: Identity) -> ChildCollection

    /// Gets path for a node for an identity.
    /// Path is an ordered collection of identities.
    /// - Complexity: Must be <= O(depth * max degree * log n)
    func path(of id: Identity) -> Path

    /// Gets identity of node at index-path.
    /// - Complexity: Must be <= O(depth * log n)
    /// - Note: This function crashes if there's no node
    ///     in this snapshot.
    func identity(at idxp: IndexPath) -> Identity

    /// Gets branchability of node for an identity.
    /// - Complexity: Must be <= O(log n)
    func branchability(of id: Identity) -> OT4Branchability
}
extension OT4SnapshotProtocol {
    ///
    /// Gets index-path for an identity.
    ///
    /// - Complexity:
    ///     Default implementation uses generic algorithm
    ///     and takes `<= O(depth * max degree * log n)` time at worst.
    ///     Override this if you can provide better performance.
    ///
    ///     As this method gets called very frequently,
    ///     performance gain by optimizing this function will be great.
    ///
    ///     Overriding this function can make huge difference
    ///     in some apps. For examples, if your children is strictly
    ///     append-only, you can use indices as a part of key,
    ///     and in that case, the function can be implemented
    ///     in `O(1)` time.
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


