//
//  VisibilityTracking2Controller.swift
//  OT4
//
//  Created by Henry on 2019/05/26.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation
import AppKit

struct VisibilityTracking2Controller {
    /// Exposed only for testing.
    /// This property can become private
    /// if testing structure gets changed.
    /// DO NOT access this property in user code.
    private(set) var root = VisibilityTracking2Tree?.none

    init() {}
    init<S>(_ ss: S, scan ov: NSOutlineView, with pxc: OT4Snapshot<S.Identity,OT4RefProxy2<S.Identity>>) where S: OT4SnapshotProtocol {
        root = ss.isEmpty ? nil : VisibilityTracking2Tree(
            with: ss.identity(at: []),
            in: ss,
            scan: ov,
            with: pxc)
    }
    var isEmpty: Bool {
        return root == nil
    }
    func findIndexPath(forVisibleRowIndex i: Int) -> IndexPath {
        precondition(root != nil)
        return root!.findIndexPath(forVisibleRowIndex: i)
    }
    func isExpanded(at idxp: IndexPath) -> Bool {
        precondition(root != nil)
        return root![idxp].isExpanded
    }

//    func find(at idxp: IndexPath) -> VisibilityTrackingTree2 {
//        precondition(root != nil)
//        return root![idxp]
//    }

    mutating func setExpanded(_ f: Bool, at idxp: IndexPath) {
        precondition(root != nil)
        root![idxp].isExpanded = f
    }
    mutating func insert(at idxp: IndexPath) {
        if idxp == [] {
            precondition(root == nil)
            root = VisibilityTracking2Tree()
        }
        else {
            let pidxp = idxp.dropLast()
            let i = idxp.last!
            root![pidxp].subtrees.insert(VisibilityTracking2Tree(), at: i)
        }
    }
    mutating func remove(at idxp: IndexPath) {
        if idxp == [] {
            precondition(root != nil)
            root = nil
        }
        else {
            let pidxp = idxp.dropLast()
            let i = idxp.last!
            root![pidxp].subtrees.remove(at: i)
        }
    }
}
