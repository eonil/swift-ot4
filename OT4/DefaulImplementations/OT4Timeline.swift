//
//  OT4Timeline.swift
//  OT4
//
//  Created by Henry on 2019/05/25.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation

/// Default implementation of `OT4TimelineProtocol`.
public struct OT4Timeline<Identity,State>: OT4TimelineProtocol, OT4DefaultProtocol where Identity: Hashable {
    public typealias Snapshot = OT4Snapshot<Identity,State>
    public typealias Identity = Snapshot.Identity
    public typealias State = Snapshot.State

    private var sss = [Snapshot.default]
    private var vers = [AnyHashable(OT4Identity())]
    /// Conceptually: `sss[i] + diffs[i] = sss[i+1]`
    /// And always `sss.count + 1 == diffs.count`.
    private var diffs = [Set<Snapshot.Identity>]()

    public init() {}
    public var startIndex: Int {
        return sss.startIndex
    }
    public var endIndex: Int {
        return sss.endIndex
    }
    public subscript(_ i: Int) -> Snapshot {
        return sss[i]
    }
    public func version(at i: Int) -> AnyHashable {
        return vers[i]
    }
    public func difference(in r: Range<Int>) -> Set<Identity> {
        precondition(r.startIndex >= sss.startIndex)
        precondition(r.endIndex <= sss.endIndex)
        var ks = Set<Identity>()
        for i in r.dropLast() {
            let diff = diffs[i]
            ks.formUnion(diff)
        }
        return ks
    }
    public func difference(at i: Int) -> Set<Snapshot.Identity> {
        precondition(i + 1 < endIndex)
        return diffs[i]
    }

    public mutating func insert(_ st: State, for id: Identity, at idxp: IndexPath) {
        clip()
        var ss = sss.last!
        ss.insert(st, for: id, at: idxp)
        sss.append(ss)
        vers.append(AnyHashable(OT4Identity()))
        diffs.append([id])
    }
    public mutating func update(_ st: State, for id: Identity, as br: OT4Branchability) {
        clip()
        var ss = sss.last!
        ss.update(st, for: id, as: br)
        sss.append(ss)
        vers.append(AnyHashable(OT4Identity()))
        diffs.append([id])
    }
    public mutating func remove(for id: Identity) {
        clip()
        var ss = sss.last!
        ss.remove(for: id)
        sss.append(ss)
        vers.append(AnyHashable(OT4Identity()))
        diffs.append([id])
    }
    private mutating func clip() {
        while sss.count > (4-1) {
            sss.removeFirst()
            vers.removeFirst()
            diffs.removeFirst()
        }
    }

    public static var `default`: OT4Timeline {
        return OT4Timeline()
    }
}
