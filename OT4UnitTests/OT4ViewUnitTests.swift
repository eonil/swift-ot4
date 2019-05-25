//
//  OT4ViewUnitTests.swift
//  OT4ViewUnitTests
//
//  Created by Henry on 2019/05/18.
//  Copyright © 2019 Eonil. All rights reserved.
//

import XCTest
import GameKit
@testable import OT4

class OT4ViewUnitTests: XCTestCase {
    func test1() {
        typealias S = OT4Source<String, String>
        typealias MV = ItemView
        typealias VC = OT4VC2<S,MV>
        typealias PX = OT4RefProxy2<String>

        let vc = VC()
        var s = S()
        XCTAssertTrue(vc.proxyTable.isEmpty)

        s.timeline.insert("aaa", for: "A", at: [])
        s.timeline.insert("aaa/aaa", for: "A/A", at: [0])
        s.timeline.insert("aaa/bbb", for: "A/B", at: [1])
        vc.process(.render(s))

        XCTAssert(!vc.proxyTable.isEmpty)
        let px = vc.proxyTable.state(of: vc.proxyTable.identity(at: []))
        XCTAssertEqual(px.identity, "A")
        XCTAssertEqual(vc.proxyTable.children(of: px.identity).count, 2)
        let A_A = vc.proxyTable.children(of: px.identity)[0]
        let A_B = vc.proxyTable.children(of: px.identity)[1]
        XCTAssertEqual(A_A, "A/A")
        XCTAssertEqual(A_B, "A/B")
        XCTAssertTrue(vc.outlineView.isExpandable(vc.proxyTable.state(of: A_A)))
        XCTAssertTrue(vc.outlineView.isExpandable(vc.proxyTable.state(of: A_B)))
        XCTAssertEqual(vc.outlineView.numberOfRows, 1)
        let px0 = vc.outlineView.item(atRow: 0) as! PX
        XCTAssertEqual(px0.identity, "A")
        vc.outlineView.expandItem(px0)
        let px1 = vc.outlineView.item(atRow: 1) as! PX
        let px2 = vc.outlineView.item(atRow: 2) as! PX
        XCTAssertEqual(px1.identity, "A/A")
        XCTAssertEqual(px2.identity, "A/B")

        let tx1 = vc.BRUTE_FORCE_treefiedIdentities()
        let tx2 = TX1<String>(value: "X", subtrees: [])
        let tx3 = TX1<String>(value: "A", subtrees: [
            TX1(value: "A/A", subtrees: []),
            TX1(value: "A/B", subtrees: []),
            ])
        XCTAssertNotEqual(tx1, tx2)
        XCTAssertEqual(tx1, tx3)
    }
//    func test2_monteCarlo() {
//        typealias S = OT4Source<OT4Timeline<String, String>>
//        typealias MV = ItemView
//        typealias VC = OT4VC<S,MV>
//        typealias PX = OT4RefProxy<String>
//        let vc = VC()
//        var s = S()
//        s.timeline.insert("aaa", for: "A", at: [])
//        vc.process(.render(s))
//
//        var uniqueSeed = 1
//        var r = ReproduciblePRNG(seed: 0)
//        func log(_ s: String) {
//            print("  \(s)")
//        }
//        let op1 = {
//            // insert random.
//            let ss = s.timeline.last!
//            let idxp = ss.makeRandomInsertionPoint(&r)
//            let id = "ID:\(uniqueSeed)"
//            s.timeline.insert("!", for: id, at: idxp)
//            s.timeline.update("!", for: id, as: .branch)
//            vc.process(.render(s))
//            let px = vc.proxyController.proxy(for: id)
//            XCTAssertEqual(vc.outlineView.isExpandable(px), true)
//            uniqueSeed += 1
//            log("insert")
//        }
//        let op2 = {
//            // update random.
//            let ss = s.timeline.last!
//            guard let id = ss.selectRandomIdentity(&r) else { return }
//            let st = ss.state(of: id)
//            let st1 = st + "+"
//            let br = OT4Branchability.random(&r)
//            s.timeline.update(st1, for: id, as: .branch)
//            vc.process(.render(s))
//            uniqueSeed += 1
//            log("update \(br)")
//        }
//        let op3 = {
//            // remove random.
//            let ss = s.timeline.last!
//            guard let id = ss.selectRandomIdentity(&r) else { return }
//            guard ss.children(of: id).isEmpty else { return }
//            s.timeline.remove(for: id)
//            vc.process(.render(s))
//            uniqueSeed += 1
//            log("remove")
//        }
//        let op4 = {
//            // expand random.
//            let ss = s.timeline.last!
//            let c = vc.outlineView.numberOfRows
//            guard c > 0 else { return }
//            let ri = r.next() % c
//            let px = vc.outlineView.item(atRow: ri) as! VC.RefProxy
//            let idxp = ss.index(of: px.identity)
//            vc.outlineView.expandItem(px, expandChildren: false)
//            log("expand \(ri) \(px.identity) \(idxp)")
//        }
//        let op5 = {
//            // collapse random.
//            let c = vc.outlineView.numberOfRows
//            guard c > 0 else { return }
//            let ri = r.next() % c
//            let px = vc.outlineView.item(atRow: ri)
//            vc.outlineView.collapseItem(px, collapseChildren: false)
//            log("collapse")
//        }
//        let op6 = {
//            // select random.
//            let c = vc.outlineView.numberOfRows
//            guard c > 0 else { return }
//            let ic = r.next() % c
//            var ris = IndexSet()
//            for _ in 0..<ic { ris.insert(r.next() % c) }
//            vc.outlineView.selectRowIndexes(ris, byExtendingSelection: false)
//            log("reset selection \(ris.count)")
//        }
//        let op7 = {
//            // select random.
//            let c = vc.outlineView.numberOfRows
//            guard c > 0 else { return }
//            let ri = r.next() % c
//            vc.outlineView.deselectRow(ri)
//            log("deselect one")
//        }
//        let cmds = [
//            op1,
//            op2,
//            op3,
//            op4,
//            op5,
//            op6,
//            op7,
//        ]
//        let c = 512
//        for i in 0..<c {
//            print("--------------------------------")
//            print("\(#function) .. \(i)/\(c)")
//            let n = r.next() % cmds.count
//            let cmd = cmds[n]
//            cmd()
//            // Verify.
//            let ss = s.timeline.last!
//            let px1 = ss.BRUTE_FORCE_treefiedProps()
//            let px2 = vc.BRUTE_FORCE_treefiedProps()
//            XCTAssertEqual(px1, px2)
////            print("\(ss.state_map)")
//            let ids = vc.BRUTE_FORCE_collectVisibleRowIdentities()
//            for (i,id) in ids.enumerated() {
//                let st = s.timeline.last!.state(of: id)
//                let px = vc.proxyController.proxy(for: id)
//                let br = vc.outlineView.isExpandable(px)
//                let xp = vc.outlineView.isItemExpanded(px)
//                let lv = vc.outlineView.level(forItem: px)
//                let prefix = String(repeating: "  ", count: lv)
//                let sign = br ? (xp ? "-" : "+") : " "
//                let cc = ss.children(of: id).count
//                let sel = vc.outlineView.isRowSelected(i) ? "[SELECTED]" : ""
//                print("  \(prefix)\(sign) [\(i)]: [\(id)] → [\(st)] (\(cc) children) \(sel)")
//            }
//            print(vc.BRUTE_FORCE_collectVisibleRowIdentities())
//        }
//    }
}

private final class ItemView: NSTextField, OT4ItemViewProtocol {
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
