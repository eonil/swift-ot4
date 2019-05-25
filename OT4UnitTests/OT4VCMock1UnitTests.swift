//
//  OT4VCMock1UnitTests.swift
//  OT4ViewUnitTests
//
//  Created by Henry on 2019/05/19.
//  Copyright © 2019 Eonil. All rights reserved.
//

import XCTest
import GameKit
@testable import OT4

class OT4VCMock1UnitTests: XCTestCase {
    func test1_propTreeScanning1() {
        typealias Mock = OT4VCMock1
        let mock = Mock()
        mock.insert(identity: "a", with: "x", as: .branch, at: [])
        mock.insert(identity: "b", with: "y", as: .branch, at: [0])
        mock.insert(identity: "c", with: "z", as: .branch, at: [1])
        let x = mock.scanPropTree()
        XCTAssertNotNil(x)
        let x1 = x!
        XCTAssertEqual(x1[[]].value, Mock.Prop(identity: "a", state: "x", branchability: .branch))
        XCTAssertEqual(x1[[0]].value, Mock.Prop(identity: "b", state: "y", branchability: .branch))
        XCTAssertEqual(x1[[1]].value, Mock.Prop(identity: "c", state: "z", branchability: .branch))
        for _ in 0..<128 {
            mock.stepRandom()
            let ss = mock.source.timeline.last!
            let x = mock.scanPropTree()
            XCTAssertEqual(ss.isEmpty, x == nil)
            if let x = x {
                func check(_ x: TX1<Mock.Prop>) {
                    let v = x.value
                    let id = v.identity
                    let st = v.state
                    let br = v.branchability

                    let cids = ss.children(of: id)
                    XCTAssertEqual(ss.contains(id), true)
                    XCTAssertEqual(ss.state(of: id), st)
                    XCTAssertEqual(ss.branchability(of: id), br)
                    XCTAssertEqual(cids.count, x.subtrees.count)
                    for x1 in x.subtrees {
                        check(x1)
                    }
                }
                check(x)
            }
        }
    }
    func test1_propTreeScanning2() {
        typealias Mock = OT4VCMock1
        let mock = Mock()
        for _ in 0..<1024 {
            mock.stepRandom()
            let ss = mock.source.timeline.last!
            let x = mock.scanPropTree()
            XCTAssertEqual(ss.isEmpty, x == nil)
            if let x = x {
                func check(_ x: TX1<Mock.Prop>) {
                    let v = x.value
                    let id = v.identity
                    let st = v.state
                    let br = v.branchability

                    let cids = ss.children(of: id)
                    XCTAssertEqual(ss.contains(id), true)
                    XCTAssertEqual(ss.state(of: id), st)
                    XCTAssertEqual(ss.branchability(of: id), br)
                    XCTAssertEqual(cids.count, x.subtrees.count)
                    for x1 in x.subtrees {
                        check(x1)
                    }
                }
                check(x)
            }
        }
    }
    func test2_visibilityTracking1() {
        typealias Mock = OT4VCMock1
        let mock = Mock()
        mock.runRandom(15)

        // Visibles.
        func isExpanded(_ id: Mock.Identity) -> Bool {
            let px = mock.target.proxyTable.state(of: id)
            return mock.target.outlineView.isItemExpanded(px)
        }
        let ids1 = mock.scanSourceVisibleIdentities(isExpanded)
        let ids2 = mock.scanTargetVisibleIdentities()
        print(ids1)
        print(ids2)
        XCTAssertEqual(ids1, ids2)

//        mock.insert(identity: "a", with: "First.", as: .branch, at: [])
//        mock.scan
    }
}
