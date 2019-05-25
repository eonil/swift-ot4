////
////  CachingReversePathSolver.swift
////  OutlineTree4View
////
////  Created by Henry on 2019/05/18.
////  Copyright © 2019 Eonil. All rights reserved.
////
//
//import Foundation
//
/////
///// ID -> IndexPath solving usually requires `O(depth * max degree)` time.
/////
///// Caching of unit computation can improve performance greatly.
///// If everything is cached, time becomes `O(depth)`.
/////
/////
//struct CachingReversePathSolver<Snapshot> where Snapshot: OT4SnapshotProtocol & DefaultProtocol {
//    typealias Operation = OT4Operation<Snapshot>
//    typealias Identity = Snapshot.Identity
//
//    /// parent ID -> (child ID, child index)
//    /// (child ID, child index) is sorted.
//    private var table = [Identity: [(Identity, Int)]]()
//
//    private(set) var snapshot = Snapshot.default
//
//    private func index(of id: Identity, in pid: Identity) -> Int {
//        let i = snapshot.children(of: pid).firstIndex(of: id)!
//        return i
//    }
//
//    mutating func replaceSnapshot(_ s: Snapshot) {
//        snapshot = s
//        // Invalidates all caches.
//        table.removeAll()
//    }
////    mutating func invalidate(_ ids: [Identity], in s: Snapshot) {
////
////        switch op {
////        case .insert(let id):
////            let pid = s.parent(of: id)
////            table[pid, default: [:]][id] = nil
////        case .update(let id):
////            let pid = s.parent(of: id)
////            table[pid, default: [:]][id] = nil
////        case .remove(let id):
////            let pid = s.parent(of: id)
////            table[pid, default: [:]][id] = nil
////        }
////    }
//    func indexPath(for id: Identity) -> IndexPath {
//        let p = snapshot.path(of: id)
//        var idxp = IndexPath()
//        for idx in p.indices.dropLast() {
//            let idx1 = p.index(after: idx)
//            let segid = p[idx]
//            let segid1 = p[idx1]
//            let i = table[segid, default: [:]][segid1] ?? index(of: segid1, in: segid)
//            idxp.append(i)
//        }
//        return idxp
//    }
//}
