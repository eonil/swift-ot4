//
//  OT4Interaction.swift
//  OutlineTree4View
//
//  Created by Henry on 2019/05/18.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation

extension OT4VC2 {
    func scanInteraction() -> OT4Interaction<Snapshot> {
        let s = renderedSnapshot
        let vx = visibilityTracking2
        let ck = outlineView.clickedRow
        let sel = outlineView.selectedRowIndexes
        assert(s.isEmpty == vx.isEmpty)
        return OT4Interaction<Snapshot>(
            renderedSnapshot: s,
            visibilityTracking: vx,
            clickedRowIndex: ck == -1 ? nil : ck,
            selectedRowIndices: sel)
    }
}

/// Defines output of `OT4View`.
///
/// `OT4View` emits whole interaction state for each time it
/// changes. First point of this data is tracking selection.
///
/// Why Identity Based?
/// -------------------
/// This value is an output note parameter,
/// and as the OT4 is fully asynchronous,
/// at the point of receiving note,
/// any index-paths are already been
/// invalidated for user's current dataset.
/// It is useful only to find identities
/// in older snapshot that will be delievered
/// together within this value.
///
/// Also, exposing such invalidated index-paths
/// is useless and very likely to cause subtle
/// bugs.
///
public struct OT4Interaction<Snapshot> where Snapshot: OT4SnapshotProtocol {
    fileprivate let renderedSnapshot: Snapshot
    fileprivate let visibilityTracking: VisibilityTracking2Controller
    fileprivate let clickedRowIndex: Int?
    fileprivate let selectedRowIndices: IndexSet
    fileprivate let identityToIndexPathSolutionCache = LockingResolutionCache<OT4Identity,IndexPath>(solutions: [:])
    fileprivate let rowIndexToIndexPathSolutionCache = LockingResolutionCache<Int,IndexPath>(solutions: [:])

    public var selectedIdentities: OT4InteractionSelectedIdentityCollection<Snapshot> {
        return OT4InteractionSelectedIdentityCollection<Snapshot>(self)
    }
}


public struct OT4InteractionSelectedIdentityCollection<Snapshot>: BidirectionalCollection where
Snapshot: OT4SnapshotProtocol {
    public typealias Element = Snapshot.Identity

    private let state: OT4Interaction<Snapshot>
    fileprivate init(_ ix: OT4Interaction<Snapshot>) {
        state = ix
    }
    public var startIndex: IndexSet.Index {
        return state.selectedRowIndices.startIndex
    }
    public var endIndex: IndexSet.Index {
        return state.selectedRowIndices.endIndex
    }
    public func index(after i: IndexSet.Index) -> IndexSet.Index {
        return state.selectedRowIndices.index(after: i)
    }
    public func index(before i: IndexSet.Index) -> IndexSet.Index {
        return state.selectedRowIndices.index(before: i)
    }
    public subscript(_ i: IndexSet.Index) -> Snapshot.Identity {
        let ridx = state.selectedRowIndices[i]
        let idxp = state.visibilityTracking.findIndexPath(forVisibleRowIndex: ridx)
        let id = state.renderedSnapshot.identity(at: idxp)
        return id

//        let ridx = state.selectedRowIndices[i]
//        let rcch = state.rowIndexToIndexPathSolutionCache
//        let idxp = state.visibilityTracking!.findIndexPath(forVisibleRowIndex: ridx, with: { [rcch] i in return rcch[i] })
//        state.rowIndexToIndexPathSolutionCache[ridx] = idxp
//        let id = state.renderedSnapshot.identity(at: idxp)
//        return id
    }
}

/// Uses a lock because this value can be shared among multiple threads.
private final class LockingResolutionCache<K,V> where K: Hashable {
    private let exck = NSLock()
    private var map = [K:V]()
    init(solutions ss: [K:V] = [:]) {
        map = ss
    }
    subscript(_ k: K) -> V? {
        get {
            exck.lock()
            let v = map[k]
            exck.unlock()
            return v
        }
        set(v) {
            exck.lock()
            map[k] = v
            exck.unlock()
        }
    }
}
