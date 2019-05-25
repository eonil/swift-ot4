//
//  BruteForce.swift
//  OT4ViewUnitTests
//
//  Created by Henry on 2019/05/18.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation
import AppKit
@testable import OT4

typealias Prop<Snapshot> = OT4Mock1Prop<Snapshot> where Snapshot: OT4SnapshotProtocol

extension OT4SnapshotProtocol {
    @available(*,deprecated: 0)
    func BRUTE_FORCE_prop(_ id: Identity) -> Prop<Self> {
        let st = state(of: id)
        let br = branchability(of: id)
        return Prop<Self>(identity: id, state: st, branchability: br)
    }
    @available(*,deprecated: 0)
    func BRUTE_FORCE_treefiedProps() -> TX1<Prop<Self>>? {
        guard !isEmpty else { return nil }
        let rt = identity(at: [])
        return BRUTE_FORCE_treefiedProps(at: rt)
    }
    @available(*,deprecated: 0)
    private func BRUTE_FORCE_treefiedProps(at id: Identity) -> TX1<Prop<Self>> {
        let cids = children(of: id)
        let ctxs = cids.map({ cid in return BRUTE_FORCE_treefiedProps(at: cid) })
        let tx = TX1(value: BRUTE_FORCE_prop(id), subtrees: ctxs)
        return tx

    }
}

extension OT4VC2 {
    /// Returns sorted as they are in `NSOutlineView`.
    func BRUTE_FORCE_collectVisibleRowIdentities() -> [Snapshot.Identity] {
        let a = outlineView.BRUTE_FORCE_collectVisibleRowItems() as [RefProxy]
        return a.map({ ref in ref.identity })
    }
    func BRUTE_FORCE_treefiedProps() -> TX1<Prop<Snapshot>>? {
        let ss = renderedSnapshot
        return BRUTE_FORCE_treefiedRefs()?.map({ ref in return ss.BRUTE_FORCE_prop(ref.identity) })
    }
    func BRUTE_FORCE_treefiedIdentities() -> TX1<Snapshot.Identity>? {
        return BRUTE_FORCE_treefiedRefs()?.map({ ref in ref.identity })
    }
    func BRUTE_FORCE_treefiedRefs() -> TX1<RefProxy>? {
        guard !proxyTable.isEmpty else { return nil }
        let root = proxyTable.state(of: proxyTable.identity(at: [])) 
        return BRUTE_FORCE_treefied(at: root)
    }
    private func BRUTE_FORCE_treefied(at node: RefProxy) -> TX1<RefProxy> {
        return outlineView.BRUTE_FORCE_treefied(at: node)
    }
}

extension VisibilityTrackingTree2 {
    func BRUTE_FORCE_collectVisibleRowIndexPaths() -> [IndexPath] {
        let idxps = collectAllIndexPathsDFS()
        var idxps1 = [IndexPath]()
        for idxp in idxps {
            if idxp == [] {
                idxps1.append(idxp)
            }
            else {
                let pidxp = idxp.dropLast()
                if self[pidxp].isExpanded {
                    idxps1.append(idxp)
                }
            }
        }
        return idxps1
    }
}

extension NSOutlineView {
    func BRUTE_FORCE_collectVisibleRowItems<T>() -> [T] where T: AnyObject {
        var a = [T]()
        let c = numberOfRows
        for i in 0..<c {
            let o = item(atRow: i) as! T
            a.append(o)
        }
        return a
    }
    func BRUTE_FORCE_collectSelectedRowItems<T>() -> [T] where T: AnyObject {
        var a = [T]()
        for i in selectedRowIndexes {
            let o = item(atRow: i) as! T
            a.append(o)
        }
        return a
    }
    func BRUTE_FORCE_treefied<T>(at node: T) -> TX1<T> where T: AnyObject {
        var tx = TX1(value: node, subtrees: [])
        for i in 0..<numberOfChildren(ofItem: node) {
            let chld = child(i, ofItem: node) as! T
            let tx1 = BRUTE_FORCE_treefied(at: chld)
            tx.subtrees.append(tx1)
        }
        return tx
    }
}
