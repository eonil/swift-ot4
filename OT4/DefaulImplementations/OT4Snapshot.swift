//
//  OT4Snapshot.swift
//  OT4
//
//  Created by Henry on 2019/05/25.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation

/// Default implementation of `OT4SnapshotProtoco`.
public struct OT4Snapshot<Key,Value>: OT4SnapshotProtocol, OT4DefaultProtocol where Key: Hashable {
    public typealias Identity = Key
    public typealias State = Value
    public typealias Path = [Identity]
    public typealias ChildCollection = [Identity]

    internal private(set) var root_id: Key?
    internal private(set) var state_map = HAMT<Key,Value>()
    internal private(set) var parent_map = HAMT<Key,Key>()
    internal private(set) var children_map = HAMT<Key,ChildCollection>()
    internal private(set) var branchables = HAMT<Key,()>()

    public init() {}
    public var isEmpty: Bool {
        return root_id == nil
    }
    public var count: Int {
        return state_map.count
    }
    public func contains(_ id: Key) -> Bool {
        return state_map[id] != nil
    }
    public func parent(of id: Key) -> Key? {
        return parent_map[id]
    }
    public func children(of id: Key) -> [Key] {
        return children_map[id]!
    }
    public func state(of id: Key) -> Value {
        return state_map[id]!
    }
    public func identity(at idxp: IndexPath) -> Key {
        return identity(at: idxp, from: root_id!)
    }
    private func identity(at idxp: IndexPath, from id: Key) -> Key {
        switch idxp.count {
        case 0:
            return id
        default:
            let i = idxp.first!
            let idxp1 = idxp.dropFirst()
            let id1 = children(of: id)[i]
            return identity(at: idxp1, from: id1)
        }
    }
    public func branchability(of id: Key) -> OT4Branchability {
        return branchables[id] != nil ? .branch : .leaf
    }

    public mutating func insert(_ st: Value, for id: Key, at idxp: IndexPath) {
        precondition(state_map[id] == nil)
        if idxp == [] {
            precondition(root_id == nil)
            state_map[id] = st
            children_map[id] = []
            branchables[id] = ()
            root_id = id
        }
        else {
            let i = idxp.last!
            let pidxp = idxp.dropLast()
            let pid = identity(at: pidxp)
            state_map[id] = st
            parent_map[id] = pid
            children_map[id] = []
            children_map[pid, default: []].insert(id, at: i)
            branchables[id] = ()
        }
    }
    public mutating func update(_ st: Value, for id: Key, as br: OT4Branchability) {
        precondition(state_map[id] != nil)
        state_map[id] = st
        switch br {
        case .branch:   branchables[id] = ()
        case .leaf:     branchables[id] = nil
        }
    }
    public mutating func remove(for id: Key) {
        precondition(state_map[id] != nil)
        precondition(children_map[id, default: []].count == 0, "You cannot remove node with children. Remove the children first.")
        if root_id == id {
            precondition(root_id == id)
            state_map[id] = nil
            children_map[id] = nil
            root_id = nil
            branchables[id] = nil
        }
        else {
            let idxp = index(of: id)
            let i = idxp.last!
            let pidxp = idxp.dropLast()
            let pid = identity(at: pidxp)
            state_map[id] = nil
            parent_map[id] = nil
            children_map[id] = nil
            children_map[pid, default: []].remove(at: i)
            branchables[id] = nil
        }
    }

    public static var `default`: OT4Snapshot {
        return OT4Snapshot()
    }
}
extension OT4Snapshot {
    public mutating func removeSubtree(for id: Key) {
        let cids = children(of: id)
        for cid in cids.lazy.reversed() {
            removeSubtree(for: cid)
        }
        remove(for: id)
    }
}
