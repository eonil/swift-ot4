//
//  OT4vUnitTests.swift
//  OT4vUnitTests
//
//  Created by Henry on 2019/05/25.
//  Copyright © 2019 Eonil. All rights reserved.
//

import XCTest
@testable import OT4VTT2

class OT4vUnitTests: XCTestCase {
    func test1() {
        // idxp     expand  visible

        var v = VisibilityTrackingTree2()
        XCTAssertEqual(v.totalCount, 1)
        XCTAssertEqual(v.totalVisibleCount, 1)
        XCTAssertEqual(v.subtrees.totalVisibleCount, 0)
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 0), [])
        // []       false   v

        v.subtrees.insert(VisibilityTrackingTree2(), at: 0)
        XCTAssertEqual(v.totalCount, 2)
        XCTAssertEqual(v.totalVisibleCount, 1)
        XCTAssertEqual(v.subtrees.totalVisibleCount, 1)
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 0), [])
        // []       false   v
        // [0]      false

        v.isExpanded = true
        XCTAssertEqual(v.totalCount, 2)
        XCTAssertEqual(v.totalVisibleCount, 2)
        XCTAssertEqual(v.subtrees.totalVisibleCount, 1)
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 0), [])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 1), [0])
        // []       true    v
        // [0]      false   v

        v.subtrees.insert(VisibilityTrackingTree2(), at: 1)
        XCTAssertEqual(v.totalCount, 3)
        XCTAssertEqual(v.totalVisibleCount, 3)
        XCTAssertEqual(v.subtrees.totalVisibleCount, 2)
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 0), [])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 1), [0])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 2), [1])
        // []       true    v
        // [0]      false   v
        // [1]      false   v

        v.subtrees[0].subtrees.insert(VisibilityTrackingTree2(), at: 0)
        XCTAssertEqual(v.totalCount, 4)
        XCTAssertEqual(v.totalVisibleCount, 3)
        XCTAssertEqual(v.subtrees.totalVisibleCount, 2)
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 0), [])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 1), [0])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 2), [1])
        // []       true    v
        // [0]      false   v
        // [0,0]    false
        // [1]      false   v

        v.subtrees[0].isExpanded = true
        XCTAssertEqual(v.totalCount, 4)
        XCTAssertEqual(v.totalVisibleCount, 4)
        XCTAssertEqual(v.subtrees.totalVisibleCount, 3)
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 0), [])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 1), [0])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 2), [0,0])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 3), [1])
        // []       true    v
        // [0]      true    v
        // [0,0]    false   v
        // [1]      false   v

        v.subtrees[1].isExpanded = true
        XCTAssertEqual(v.totalCount, 4)
        XCTAssertEqual(v.totalVisibleCount, 4)
        XCTAssertEqual(v.subtrees.totalVisibleCount, 3)
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 0), [])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 1), [0])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 2), [0,0])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 3), [1])
        // []       true    v
        // [0]      true    v
        // [0,0]    false   v
        // [1]      true    v

        v.subtrees[1].subtrees.insert(VisibilityTrackingTree2(), at: 0)
        XCTAssertEqual(v.totalCount, 5)
        XCTAssertEqual(v.totalVisibleCount, 5)
        XCTAssertEqual(v.subtrees.totalVisibleCount, 4)
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 0), [])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 1), [0])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 2), [0,0])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 3), [1])
        // []       true    v
        // [0]      true    v
        // [0,0]    false   v
        // [1]      true    v
        // [1,0]    false   v

        v.isExpanded = false
        XCTAssertEqual(v.totalCount, 5)
        XCTAssertEqual(v.totalVisibleCount, 1)
        XCTAssertEqual(v.subtrees.totalVisibleCount, 4)
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 0), [])
        // []       false   v
        // [0]      true
        // [0,0]    false
        // [1]      true
        // [1,0]    false

        v.isExpanded = true
        XCTAssertEqual(v.totalCount, 5)
        XCTAssertEqual(v.totalVisibleCount, 5)
        XCTAssertEqual(v.subtrees.totalVisibleCount, 4)
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 0), [])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 1), [0])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 2), [0,0])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 3), [1])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 4), [1,0])
        // []       true    v
        // [0]      true    v
        // [0,0]    false   v
        // [1]      true    v
        // [1,0]    false   v

        v.subtrees[1].isExpanded = false
        XCTAssertEqual(v.totalCount, 5)
        XCTAssertEqual(v.totalVisibleCount, 4)
        XCTAssertEqual(v.subtrees.totalVisibleCount, 3)
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 0), [])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 1), [0])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 2), [0,0])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 3), [1])
        // []       true    v
        // [0]      true    v
        // [0,0]    false   v
        // [1]      false   v
        // [1,0]    false

        v.subtrees[0].isExpanded = false
        XCTAssertEqual(v.totalCount, 5)
        XCTAssertEqual(v.totalVisibleCount, 3)
        XCTAssertEqual(v.subtrees.totalVisibleCount, 2)
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 0), [])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 1), [0])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 2), [1])

        // []       true    v
        // [0]      false   v
        // [0,0]    false
        // [1]      false   v
        // [1,0]    false

        v.subtrees[0].isExpanded = true
        XCTAssertEqual(v.totalCount, 5)
        XCTAssertEqual(v.totalVisibleCount, 4)
        XCTAssertEqual(v.subtrees.totalVisibleCount, 3)
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 0), [])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 1), [0])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 2), [0,0])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 3), [1])
        // []       true    v
        // [0]      true    v
        // [0,0]    false   v
        // [1]      false   v
        // [1,0]    false

        v.isExpanded = false
        XCTAssertEqual(v.totalCount, 5)
        XCTAssertEqual(v.totalVisibleCount, 1)
        XCTAssertEqual(v.subtrees.totalVisibleCount, 3)
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 0), [])
        // []       false   v
        // [0]      true
        // [0,0]    false
        // [1]      false
        // [1,0]    false

        v.isExpanded = true
        XCTAssertEqual(v.totalCount, 5)
        XCTAssertEqual(v.totalVisibleCount, 4)
        XCTAssertEqual(v.subtrees.totalVisibleCount, 3)
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 0), [])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 1), [0])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 2), [0,0])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 3), [1])
        // []       true    v
        // [0]      true    v
        // [0,0]    false   v
        // [1]      false   v
        // [1,0]    false

        v.isExpanded = false
        XCTAssertEqual(v.totalCount, 5)
        XCTAssertEqual(v.totalVisibleCount, 1)
        XCTAssertEqual(v.subtrees.totalVisibleCount, 3)
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 0), [])
        // []       false   v
        // [0]      true
        // [0,0]    false
        // [1]      false
        // [1,0]    false

        v.subtrees[0].isExpanded = false
        XCTAssertEqual(v.totalCount, 5)
        XCTAssertEqual(v.totalVisibleCount, 1)
        XCTAssertEqual(v.subtrees.totalVisibleCount, 2)
        XCTAssertEqual(v.subtrees[0].totalVisibleCount, 1)
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 0), [])
        // []       false   v
        // [0]      false
        // [0,0]    false
        // [1]      false
        // [1,0]    false

        v.isExpanded = true
        XCTAssertEqual(v.totalCount, 5)
        XCTAssertEqual(v.totalVisibleCount, 3)
        XCTAssertEqual(v.subtrees.totalVisibleCount, 2)
        XCTAssertEqual(v.subtrees[0].totalVisibleCount, 1)
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 0), [])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 1), [0])
        XCTAssertEqual(v.findIndexPath(forVisibleRowIndex: 2), [1])
        // []       true    v
        // [0]      false   v
        // [0,0]    false
        // [1]      false   v
        // [1,0]    false
    }
}
