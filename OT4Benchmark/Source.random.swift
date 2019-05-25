////
////  Source.random.swift
////  OT4Benchmark
////
////  Created by Henry on 2019/05/25.
////  Copyright © 2019 Eonil. All rights reserved.
////
//
//import Foundation
//import OT4
//
//private let idxs = Array(0..<1_000_000).shuffled()
//
////extension OT4Timeline {
////    func randomIndexPath(_ i: Int) -> IndexPath {
////        return last!.randomIndexPath(i)
////    }
////}
//extension OT4Snapshot {
//    func randomIndexPath(_ i: Int) -> IndexPath {
//        if isEmpty { return [] }
//        let id = identity(at: [])
//        return randomIndexPath(from: id, i)
//    }
//    private func randomIndexPath(from root: Identity, _ i: Int) -> IndexPath {
//        let cs = children(of: root)
//        guard cs.count > 0 else { return [] }
//        let n = idxs[i] % cs.count
//        let c = cs[n]
//        return IndexPath().appending(n).appending(randomIndexPath(from: c, i.hashValue)) 
//    }
//}
