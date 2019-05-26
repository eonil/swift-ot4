//
//  OT4TimelineProtocol.swift
//  OT4
//
//  Created by Henry on 2019/05/25.
//  Copyright © 2019 Eonil. All rights reserved.
//

/// Collection of snapshots over time.
/// It is strongly recommend to keep snapshot count <= 4.
/// As `OT4View` has to iterate all snapshots in a timeline,
/// keeping `n` snapshot multiplies `OT4View` processing time
/// by `n`.
///
public protocol OT4TimelineProtocol: RandomAccessCollection where Self.Element == Snapshot {
    associatedtype Snapshot: OT4SnapshotProtocol
    typealias Identity = Snapshot.Identity

    ///
    /// Version of snapshot at index.
    ///
    /// Version is opposite concept to hash.
    /// You can ensure equality if versions of two snapshots are equal.
    /// Otherwise, two snapshots can be either of equal or inequal.
    ///
    /// All versions in a process MUST be GLOBALLY UNIQUE.
    ///
    func version(at i: Index) -> AnyHashable

    ///
    /// Gets differences from snapshot at index to snapshot at index.
    ///
    /// This value is supposed to be passed with before/after snapshots
    /// and you can recover index-path of each element in each snapshot.
    ///
    /// OT4 will detect what kind of change has been performed by comparing
    /// position in each snapshots.
    ///
    /// It's up to implementation how designated nodes are positioned
    /// in snapshot.
    ///
    func difference(in range: Range<Index>) -> Set<Identity>
}
//extension OT4TimelineProtocol {
//    func differences(after i: Index) -> Set<Identity> {
//
//    }
//}
extension OT4TimelineProtocol {
    func findIndex(for ver: AnyHashable) -> Index? {
        for i in indices.lazy.reversed() {
            if ver == version(at: i) {
                return i
            }
        }
        return nil
    }
    var lastVersion: AnyHashable {
        let i = index(before: endIndex)
        return version(at: i)
    }
}
