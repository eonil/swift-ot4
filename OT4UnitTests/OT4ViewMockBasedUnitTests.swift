//
//  OT4ViewMockBasedUnitTests.swift
//  OT4ViewUnitTests
//
//  Created by Henry on 2019/05/19.
//  Copyright © 2019 Eonil. All rights reserved.
//

import XCTest
import GameKit
@testable import OT4

class OT4ViewMockBasedUnitTests: XCTestCase {
    func testCase1() {
        typealias Mock = OT4VCMock1
        let mock = Mock()
        for _ in 0..<16 { mock.stepRandom() }
        print("--------")
        mock.logSourceState()
        mock.logTargetState()
        mock.logTargetVisibilityTree()
        print("--------")
        mock.stepRandom()
        mock.logSourceState()
        mock.logTargetState()
        mock.logTargetVisibilityTree()
        let ss = mock.target.renderedSnapshot
        let vxc = mock.target.visibilityTracking2
        if let idxps = vxc.root?.collectAllIndexPathsDFS() {
            for idxp in idxps {
                let vx = vxc.root![idxp]
                let id = ss.identity(at: idxp)
                let px = mock.target.proxyTable.state(of: id)
                let xp = mock.target.outlineView.isItemExpanded(px)
                XCTAssertEqual(vx.isExpanded, xp)
            }
        }
    }
    func testCase2() {
        typealias Mock = OT4VCMock1
        let mock = Mock()
        mock.target.note = { n in
            switch n {
            case .interaction(_):
                XCTAssertEqual(mock.target.renderedSnapshot.isEmpty, mock.target.visibilityTracking2.isEmpty)
                mock.logTargetState()
                mock.logTargetVisibilityTree()
                let vxc = mock.target.visibilityTracking2
                guard let idxps = vxc.root?.collectAllIndexPathsDFS() else { break }
                let ss = mock.target.renderedSnapshot
                for idxp in idxps {
                    let vx = vxc.root![idxp]
                    let id = ss.identity(at: idxp)
                    let px = mock.target.proxyTable.state(of: id)
                    let xp = mock.target.outlineView.isItemExpanded(px)
                    XCTAssertEqual(vx.isExpanded, xp)
                }
            }
        }
        let c = 93
        for _ in 0..<c { mock.stepRandom() }
        print("--------------------------------")
        mock.logTargetState()
        mock.logTargetVisibilityTree()
        mock.stepRandom()
    }
    func testMonteCarlo() {
        typealias Mock = OT4VCMock1
        let mock = Mock()
        mock.target.note = { n in
            switch n {
            case .interaction(let ix):
                XCTAssertEqual(mock.target.renderedSnapshot.isEmpty, mock.target.visibilityTracking2.isEmpty)
//                mock.logSourceState()
//                mock.logTargetState()
//                mock.logTargetVisibilityTree()
//                guard let vxc = mock.target.visibilityTracking else { break }
//                let idxps = vxc.root.collectAllIndexPathsDFS()
//                let ss = mock.target.renderedSnapshot
//                for idxp in idxps {
//                    let vx = vxc.root[idxp]
//                    let id = ss.identity(at: idxp)
//                    let px = mock.target.proxyController.proxy(for: id)
//                    let xp = mock.target.outlineView.isItemExpanded(px)
//                    XCTAssertEqual(vx.isExpanded, xp)
//                }
            }
        }
        let c = 1024
//        mock.allowsLogPrinting = false
        for i in 0..<c {
            print("--------------------------------")
            print("\(#function) .. \(i + 1)/\(c)")
            mock.stepRandom()
            // Verify.
            let s = mock.source
            let vc = mock.target
            let ss = s.timeline.last!
            let px1 = ss.BRUTE_FORCE_treefiedProps()
            let px2 = vc.BRUTE_FORCE_treefiedProps()
            XCTAssertEqual(s.timeline.last!.isEmpty, vc.renderedSnapshot.isEmpty)
            XCTAssertEqual(s.timeline.last!.isEmpty, vc.proxyTable.isEmpty)
            XCTAssertEqual(s.timeline.last!.isEmpty, vc.visibilityTracking2.isEmpty)
            XCTAssertEqual(px1, px2)
            XCTAssertEqual(mock.source.timeline.last!.isEmpty, px1 == nil)
            XCTAssertEqual(mock.target.outlineView.numberOfRows == 0, px2 == nil)

            // Check visibilities.
            func isExpanded(_ id: Mock.Identity) -> Bool {
                let px = mock.target.proxyTable.state(of: id)
                return mock.target.outlineView.isItemExpanded(px)
            }
            let ids1 = mock.scanSourceVisibleIdentities(isExpanded)
            let ids2 = mock.scanTargetVisibleIdentities()
            XCTAssertEqual(ids1, ids2)

            // Check expansions.
            XCTAssertEqual(mock.target.renderedSnapshot.isEmpty, mock.target.visibilityTracking2.isEmpty)

            if let idxps = mock.target.visibilityTracking2.root?.collectAllIndexPathsDFS() {
                let ss = mock.target.renderedSnapshot
                for idxp in idxps {
                    let vx = mock.target.visibilityTracking2.root![idxp]
                    let id = ss.identity(at: idxp)
                    let px = mock.target.proxyTable.state(of: id)
                    let xp = mock.target.outlineView.isItemExpanded(px)
                    XCTAssertEqual(vx.isExpanded, xp)
                }
            }

            //            // Selection.
            //            let sel = mock.scanTargetSelectedIdentities()
            //            XCTAssertEqual(mock.target.outlineView.numberOfSelectedRows, sel.count)
        }
    }
}
