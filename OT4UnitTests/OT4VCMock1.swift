//
//  OT4VCMock1.swift
//  OT4ViewUnitTests
//
//  Created by Henry on 2019/05/19.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation
import AppKit
import GameKit
import XCTest
@testable import OT4

///
/// Mock 1 for OT4VC.
///
/// A framework to make comparison of input/output easier.
///
/// Mock accepts simplified input and perform multiple accumultive
/// simulation. Mock also provides simplified scanning output.
///
/// DO NOT modify once written mock.
/// Updating mock randomization algorithm can change simulation
/// and yield unexpected behavior in test.
///
final class OT4VCMock1 {
    typealias Source = OT4Source<String, String>
    typealias RefProxy = OT4RefProxy2<String>
    typealias Target = OT4VC2<Source,OT4VCMockDummyItemView>
    typealias Identity = Source.Timeline.Snapshot.Identity
    typealias State = Source.Timeline.Snapshot.State
    typealias Prop = OT4Mock1Prop<Source.Timeline.Snapshot>

    private var s = Source()
    private var vc = Target()
    private var uniqueSeed = 0
    private var r: ReproduciblePRNG
    private var commandRPNG = ReproduciblePRNG(seed: 0)

    init(rprng: ReproduciblePRNG = ReproduciblePRNG(seed: 0)) {
        r = rprng
    }
    private var ss: Source.Timeline.Snapshot {
        return s.timeline.last!
    }
    var source: Source {
        return s
    }
    var target: Target {
        return vc
    }


//    var allowsLogPrinting = true
    private func log(_ s: String) {
//        guard allowsLogPrinting else { return }
        print(s)
    }
    func logSourceState() {
        log("[SOURCE PROP TREE]")
        let x = ss.BRUTE_FORCE_treefiedProps()
        let all = x?.collectAllEnumeratedDFS() ?? []
        var i = 0
        for (idxp,x1) in all {
            let p = x1.value
            let id = p.identity
            let st = p.state
            let br = p.branchability == .branch ? "b" : "l"
            let lv = idxp.count
            let prefix = String(repeating: "  ", count: lv)
            let sign = br
            let cc = ss.children(of: id).count
            log("  \(prefix)\(sign) [\(i)]: [\(id)] → [\(st)] (\(cc) children)")
            i += 1
        }
    }
    func logTargetState() {
        log("[TARGET TREE] (prop/visibility/expansion)")
        let ids = vc.BRUTE_FORCE_collectVisibleRowIdentities()
        for (i,id) in ids.enumerated() {
            let st = s.timeline.last!.state(of: id)
            let px = vc.proxyTable.state(of: id)
            let br = vc.outlineView.isExpandable(px)
            let xp = vc.outlineView.isItemExpanded(px)
            let lv = vc.outlineView.level(forItem: px)
            let prefix = String(repeating: "  ", count: lv)
            let sign = br ? (xp ? "-" : "+") : " "
            let cc = ss.children(of: id).count
            let sel = vc.outlineView.isRowSelected(i) ? "[SELECTED]" : ""
            log("  \(prefix)\(sign) [\(i)]: [\(id)] → [\(st)] (\(cc) children) \(sel)")
        }
    }
    func logTargetVisibilityTree() {
        guard let x = vc.visibilityTracking2.root else {
            log("(no visibility tree)")
            return
        }

        log("[VISIBILITY TREE]")
        let xs = x.collectAllEnumeratedDFS()
        var i = 0
        for (idxp,x) in xs {
            let lv = idxp.count
            let sign = x.isExpanded ? "expanded" : "collapsed"
            let prefix = String(repeating: "  ", count: lv)
            let id = vc.renderedSnapshot.identity(at: idxp)
            let tz = x.totalCount
            let vz = x.totalVisibleCount
            log("  \(prefix)\(sign) [\(i)]: [\(id)] (total: \(tz), visible: \(vz))")
            i += 1
        }
    }
//    ///
//    /// Prints target's expansion state in `NSOutlineView`.
//    ///
//    func logTargetFinalViewExpansionTree() {
//
//    }


    func stepRandom() {
        let cmds = [
            insertRandom,
            updateRandom,
            removeRandom,
            expandRandom,
            collapseRandom,
            selectRandom,
            deselectRandom,
        ]
        let n = commandRPNG.next() % cmds.count
        let cmd = cmds[n]
        cmd()
    }
    func runRandom(_ n: Int) {
        for _ in 0..<n {
            stepRandom()
        }
    }

    func makeID() -> String {
        uniqueSeed += 1
        return "ID:\(uniqueSeed)"
    }


    func insert(identity id: String, with st: String, as br: OT4Branchability, at idxp: IndexPath) {
        s.timeline.insert(st, for: id, at: idxp)
        s.timeline.update(st, for: id, as: br)
        vc.process(.render(s))
    }
    func update(identity id: String, with st: String, as br: OT4Branchability) {
        s.timeline.update(st, for: id, as: br)
        vc.process(.render(s))
    }

    func insertRandom() {
        if ss.isEmpty {
            s.timeline.insert("aaa", for: "A", at: [])
            vc.process(.render(s))
        }
        else {
            let idxp = ss.makeRandomInsertionPoint(&r)
            let id = makeID()
            s.timeline.insert("!", for: id, at: idxp)
            s.timeline.update("!", for: id, as: .branch)
            vc.process(.render(s))
            let px = vc.proxyTable.state(of: id)
            XCTAssertEqual(vc.outlineView.isExpandable(px), true)
        }
        log("insert")
    }
    func updateRandom() {
        guard let id = ss.selectRandomIdentity(&r) else { return }
        let st = ss.state(of: id)
        let st1 = st + "+"
        s.timeline.update(st1, for: id, as: .branch)
        log("update to \(st1), branch")
        vc.process(.render(s))
    }
    func removeRandom() {
        guard let id = ss.selectRandomIdentity(&r) else { return }
        guard ss.children(of: id).isEmpty else { return }
        s.timeline.remove(for: id)
        log("remove")
        vc.process(.render(s))
    }
    func expandRandom() {
        let c = vc.outlineView.numberOfRows
        guard c > 0 else { return }
        let ri = r.next() % c
        let px = vc.outlineView.item(atRow: ri) as! RefProxy
        let idxp = ss.index(of: px.identity)
        log("expand \(ri) \(px.identity) \(idxp)")
        vc.outlineView.expandItem(px, expandChildren: false)
    }
    func collapseRandom() {
        let c = vc.outlineView.numberOfRows
        guard c > 0 else { return }
        let ri = r.next() % c
        let px = vc.outlineView.item(atRow: ri) as! RefProxy
        log("collapse \(ri) \(px.identity)")
        vc.outlineView.collapseItem(px, collapseChildren: false)
    }
    func selectRandom() {
        let c = vc.outlineView.numberOfRows
        guard c > 0 else { return }
        let ic = r.next() % c
        var ris = IndexSet()
        for _ in 0..<ic { ris.insert(r.next() % c) }
        log("reset selection \(ris.count)")
        vc.outlineView.selectRowIndexes(ris, byExtendingSelection: false)
    }
    func deselectRandom() {
        let c = vc.outlineView.numberOfRows
        guard c > 0 else { return }
        let ri = r.next() % c
        log("deselect one")
        vc.outlineView.deselectRow(ri)
    }
}
extension OT4VCMock1 {
    func scanSourceAllIdentitiesInDFSOrder() -> [Identity] {
        let ss = s.timeline.last!
        guard let x = ss.BRUTE_FORCE_treefiedProps() else { return [] }
        let ids = x.collectAll().map({ x1 in x1.value.identity })
        return ids
    }
    // "visibles" cannot be defined for source as source does not
    // keep expansion state.
    func scanSourceVisibleIdentities(_ isExpanded: (Identity) -> Bool) -> [Identity] {
        guard let x = ss.BRUTE_FORCE_treefiedProps() else { return [] }
        let ids = x.collectAllEnumeratedDFS(isIncluded: { idxp,x1 in
            if idxp == [] { return true }
            let pidxp = idxp.dropLast()
            let pid = x[pidxp].value.identity
            return isExpanded(pid)
        }).map({ idxp,x1 in x1.value.identity })
        return ids
    }

    func scanTargetAllIdentitiesInDFSOrder() -> [Identity] {
        guard let x = vc.BRUTE_FORCE_treefiedIdentities() else { return [] }
        return x.collectAll().map({ x in x.value })
    }
    func scanTargetVisibleIdentities() -> [Identity] {
        return vc.BRUTE_FORCE_collectVisibleRowIdentities()
    }
    func scanTargetSelectedIdentities() -> [Identity] {
        let visibles = vc.BRUTE_FORCE_collectVisibleRowIdentities()
        let sel = vc.outlineView.selectedRowIndexes
        var ids = [Identity]()
        for (i,id) in visibles.enumerated() {
            if sel.contains(i) {
                ids.append(id)
            }
        }
        return ids
    }

    func scanProp(at idxp: IndexPath) -> Prop {
        let id = ss.identity(at: idxp)
        return scanProp(at: id)
    }
    func scanProp(at id: Identity) -> Prop {
        let st = ss.state(of: id)
        let br = ss.branchability(of: id)
        return Prop(identity: id, state: st, branchability: br)
    }
    func scanPropTree() -> TX1<Prop>? {
        guard !ss.isEmpty else { return nil }
        let rt = ss.identity(at: IndexPath())
        return scanPropTree(at: rt)
    }
    private func scanPropTree(at id: Identity) -> TX1<Prop>? {
        let cids = ss.children(of: id)
        let ctxs = cids.map({ cid in return scanPropTree(at: cid)! })
        let tx = TX1(value: scanProp(at: id), subtrees: ctxs)
        return tx
    }
}

///
/// Snapshot of single node.
///
struct OT4Mock1Prop<Snapshot> where Snapshot: OT4SnapshotProtocol {
    var identity: Snapshot.Identity
    var state: Snapshot.State
    var branchability: OT4Branchability
}
extension OT4Mock1Prop: Equatable where Snapshot.State: Equatable {}


final class OT4VCMockDummyItemView: NSTextField, OT4ItemViewProtocol {
    typealias State = String
    func control(_ c: OT4ItemViewControl<String>) {
        switch c {
        case .render(let s):
            stringValue = s
        }
    }
    var note: ((Note) -> Void)?
}

private extension OT4Snapshot where Identity: Comparable {
    func selectRandomIdentity(_ r: inout ReproduciblePRNG) -> Identity? {
        guard let kv = state_map.reproducibleRandom(&r) else { return nil }
        return kv.0
    }
    func makeRandomInsertionPoint(_ r: inout ReproduciblePRNG) -> IndexPath {
        guard let pid = selectRandomIdentity(&r) else { return [] }
        let ci = r.next() % (children(of: pid).count + 1)
        let idxp = index(of: pid).appending(ci)
        return idxp
    }
}

private extension OT4Branchability {
    static func random(_ r: inout ReproduciblePRNG) -> OT4Branchability {
        switch r.next() % 2 {
        case 0:     return .branch
        default:    return .leaf
        }
    }
}
