//
//  OT4Snapshot.swift
//  OT4
//
//  Created by Henry on 2019/05/25.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation

/// Default implementation of `OT4SnapshotProtocol`.
///
/// This wraps a naive implementation with a small cache.
///
/// Questions
/// ---------
/// Current HAMT implementation is 2x-50x
/// times slower than `Swift.Dictionary`.
/// Would having small local cache as `Swift.Dictionary`
/// improve performance?
/// A quick trial actually dropped performance.
/// I don't think it's possible as look-up in such
/// cache involves extra steps of far pointer jump.
///
public struct OT4Snapshot<Key,Value>: OT4SnapshotProtocol, OT4DefaultProtocol where Key: Hashable {
    public typealias Identity = Key
    public typealias State = Value
    public typealias Path = [Identity]
    public typealias ChildCollection = [Identity]

    private(set) var naive = OT4NaiveSnapshot<Key,Value>()

    public init() {}
    public var isEmpty: Bool {
        return naive.isEmpty
    }
    public var count: Int {
        return naive.count
    }
    public var identities: IdentitySequence {
        return IdentitySequence(source: naive.identities)
    }
    public struct IdentitySequence: Sequence {
        var source: HAMT<Key,Value>.KeySequence
        public func makeIterator() -> Iterator {
            return Iterator(source: AnyIterator(source.makeIterator()))
//            return Iterator(source: source.makeIterator())
        }
        public struct Iterator: IteratorProtocol {
            var source: AnyIterator<Identity>
            // Using concrete type here makes compiler crash.
            // Uncomment this line if compiler gets better.
//            var source: HAMT<Key,Value>.KeySequence.Iterator
            public mutating func next() -> Identity? {
                return source.next()
            }
        }
    }


    public func contains(_ id: Key) -> Bool {
        return naive.contains(id)
    }
    public func parent(of id: Key) -> Key? {
        return naive.parent(of: id)
    }
    public func children(of id: Key) -> [Key] {
        return naive.children(of: id)
    }
    public func state(of id: Key) -> Value {
        return naive.state(of: id)
    }
    public func identity(at idxp: IndexPath) -> Key {
        return naive.identity(at: idxp)
    }
    public func branchability(of id: Key) -> OT4Branchability {
        return naive.branchability(of: id)
    }

    public mutating func insert(_ st: Value, for id: Key, at idxp: IndexPath) {
        naive.insert(st, for: id, at: idxp)
    }
    public mutating func update(_ st: Value, for id: Key, as br: OT4Branchability) {
        naive.update(st, for: id, as: br)
    }
    public mutating func remove(for id: Key) {
        naive.remove(for: id)
    }

    public static var `default`: OT4Snapshot {
        return OT4Snapshot()
    }
}
