//
//  VisibilityTracking2Tree.swift
//  OT4VTTUnitTests
//
//  Created by Henry on 2019/05/25.
//  Copyright © 2019 Eonil. All rights reserved.
//

///
/// Provides index-path resolution from various inputs in acceptable time.
///
/// This tree tracks count and expansion state of each subtree
/// to resolve index-path faster.
///
/// - Note:
///     Initialization copies whole source-tree and takes
///     O(n) where n is size of source tree.
///     You can insert/modify/remove element in existing tree
///     and it will take O(depth).
///
/// - Note:
///     Performance can be improved by employing summation B-Tree. (SBTL)
///     In that case, performance would be O(depth * log(max degree)).
///
struct VisibilityTracking2Tree: OT4TreeProtocol, OT4MutableTreeProtocol {
    var isExpanded = false
    var subtrees = VTTSubtreeCollection()

    var totalCount: Int {
        return 1 + subtrees.totalCount
    }
    var totalVisibleCount: Int {
        return 1 + (isExpanded ? subtrees.totalVisibleCount : 0)
    }
}
struct VTTSubtreeCollection: RandomAccessCollection, MutableCollection {
    private var elements = [VisibilityTracking2Tree]()
    private(set) var totalCount = 0
    private(set) var totalVisibleCount = 0
    var startIndex: Int {
        return 0
    }
    var endIndex: Int {
        return elements.count
    }
    subscript(_ i: Int) -> VisibilityTracking2Tree {
        get { return elements[i] }
        set(x) { replace(at: i, with: x) }
    }
    mutating func insert(_ x: VisibilityTracking2Tree, at i: Int) {
        elements.insert(x, at: i)
        totalCount += x.totalCount
        totalVisibleCount += x.totalVisibleCount
    }
    mutating func remove(at i: Int) {
        let old = elements[i]
        totalCount -= old.totalCount
        totalVisibleCount -= old.totalVisibleCount
        elements.remove(at: i)
    }
    mutating func replace(at i: Int, with x: VisibilityTracking2Tree) {
        let old = elements[i]
        totalCount -= old.totalCount
        totalVisibleCount -= old.totalVisibleCount
        elements[i] = x
        totalCount += x.totalCount
        totalVisibleCount += x.totalVisibleCount
    }
}

import Foundation
extension VisibilityTracking2Tree {
    func findIndexPath(forVisibleRowIndex i: Int, with presolutions: (Int) -> IndexPath?) -> IndexPath {
        if let p = presolutions(i) { return p }
        return findIndexPath(forVisibleRowIndex: i)
    }
    ///
    /// Resolves index-path for given row-index.
    ///
    /// For given tree with n visible elements,
    /// - O(depth * max degree) at average if the tree is well balanced.
    ///   O(depth * max degree) is guaranteed to be < O(n).
    /// - O(1) at best if you're resolving for a consecutive
    ///   sibling with cached resolution.
    /// - O(n) at worst.
    ///
    /// Worst case is equal with DFS based approach,
    /// But DFS based approach requires sequential iteration
    /// over all intermediate visible nodes, later node
    /// take more time to access regardless of balancing
    /// of tree.
    ///
    /// This approach provides fair access time
    /// for all nodes if tree is well balanced.
    /// As outline selection is fully random,
    /// this approach is very likely able to provide more
    /// stable performance.
    ///
    /// For unbalanced tree, especially for very deep trees,
    /// performance will be dropped. But this is same with
    /// DFS based approach.
    ///
    /// Dataset for UI element is likely to be less then 1000.
    /// Because in UX, very large dataset means worse UX,
    /// therefore, should be avoided.
    ///
    /// - Parameter presolutions:
    ///     Row-index to index-path mapping that already been solved.
    ///     If you have resolved index-path for consecutive sibling node
    ///     of target node, target node's index-path will be resolved
    ///     in O(1) time.
    ///
    /// - TODO:
    ///     Replace `subtrees` to B-Tree and modify algorithm
    ///     to manage and utilize extra counting informations
    ///     to gain O(depth * log(max degree)) performance.
    ///
    func findIndexPath(forVisibleRowIndex i: Int) -> IndexPath {
        //        if let idxp = presolutions(i) { return idxp } // Return cached result.
        //        if i == 0 { return [] }
        //        // Check previous one.
        //        if let idxp = presolutions(i - 1) {
        //            let j = idxp.last! - 1
        //            if j > 0 {
        //                let idxp1 = idxp.dropLast()
        //                let idxp2 = idxp1.appending(j)
        //                return idxp2
        //            }
        //        }
        //        // Check next one.
        //        if let idxp = presolutions(i + 1) {
        //            let j = idxp.last! + 1
        //            let idxp1 = idxp.dropLast()
        //            let idxp2 = idxp1.appending(j)
        //            let n = self[idxp1]
        //            assert(n.isExpanded)
        //            if j < n.subtrees.count {
        //                return idxp2
        //            }
        //        }

        
        guard i < totalVisibleCount else { fatalError("Index is out of range.") }
        if i == 0 { return [] }
        var j = i - 1
        for (k,n) in subtrees.enumerated() {
            if j < n.totalVisibleCount {
                return IndexPath().appending(k).appending(n.findIndexPath(forVisibleRowIndex: j))
            }
            j -= n.totalVisibleCount
        }
        fatalError("A bug in algorithm.")
    }
}

import AppKit
extension VisibilityTracking2Tree {
    ///
    /// Initializes new tracking tree by copying structure
    /// of target subtree in a flat snapshot.
    ///
    /// - Parameter with id:
    ///     Identity of node to be initialized with.
    ///     New tree will be constructed to copy structure
    ///     of target subtree and current expansion state
    ///     of an outline-view.
    ///
    /// - Parameter in s:
    ///     Snapshot container of target subtree.
    ///
    /// - Parameter scan ov:
    ///     Visibility tracking tree needs to track current
    ///     expansion state of outline-view to be initialized
    ///     correctly. Otherwise, you can lose some tracking
    ///     information, and that can cause resolution
    ///     problems.
    ///
    init<S>(with id: S.Identity, in s: S, scan ov: NSOutlineView, with pxc: OT4Snapshot<S.Identity,OT4RefProxy2<S.Identity>>) where S: OT4SnapshotProtocol {
        let px = pxc.state(of: id)
        let xp = ov.isItemExpanded(px)
        isExpanded = xp
        for cid in s.children(of: id) {
            let x1 = VisibilityTracking2Tree(with: cid, in: s, scan: ov, with: pxc)
            subtrees.insert(x1, at: subtrees.count)
        }
    }
}
