//
//  main.swift
//  OT4Benchmark
//
//  Created by Henry on 2019/05/25.
//  Copyright © 2019 Eonil. All rights reserved.
//

import OT4

benchmark()

//
//typealias Source = OT4Source<Int,Int>
//typealias VC = OT4VC<Source,OT4ItemView<Int>>
//enum Op: String, CustomStringConvertible {
//    case insert     =   "insert"
//    case update     =   "update"
//    case remove     =   "remove"
//    case expand     =   "expand"
//    case collapse   =   "collapse"
//    var description: String {
//        return rawValue
//    }
//    static let all = [.insert, .insert, .update, .remove, .expand, .collapse] as [Op]
//}
//
//print("preparing...")
//let vc = VC()
//var src = Source()
//let c = 1_000_000
//let opidxs = Array(0..<c).shuffled()
//let ks = Array(0..<c).shuffled()
//let vs = Array(0..<c).shuffled()
//var opcounter = [Op: Int]()
//
//print("started.")
//src.timeline.insert(c, for: c, at: [])
//vc.process(.render(src))
//for i in 0..<c {
//    let op = Op.all[opidxs[i] % Op.all.count]
//    switch op {
//    case .insert:
//        let idxp = src.timeline.last!.randomIndexPath(i)
//        let idxp1 = (idxp != [] || opidxs[i] % 2 == 0) ? idxp : idxp.appending(0)
//        guard idxp1 != [] else { break }
//        let k = ks[i]
//        let v = vs[i]
//        src.timeline.insert(v, for: k, at: idxp1)
//        vc.process(.render(src))
//        opcounter[op, default: 0] += 1
//    case .update:
//        guard !src.timeline.last!.isEmpty else { break }
//        let idxp = src.timeline.last!.randomIndexPath(i)
//        let k = src.timeline.last!.identity(at: idxp)
//        let v = vs[i]
//        let br = (opidxs[i] % 2 == 0 ? .branch : .leaf) as OT4Branchability
//        src.timeline.update(v, for: k, as: br)
//        vc.process(.render(src))
//        opcounter[op, default: 0] += 1
//    case .remove:
//        guard !src.timeline.last!.isEmpty else { break }
//        let idxp = src.timeline.last!.randomIndexPath(i)
//        guard idxp != [] else { break }
//        let k = src.timeline.last!.identity(at: idxp)
//        src.timeline.remove(for: k)
//        vc.process(.render(src))
//        opcounter[op, default: 0] += 1
//    case .expand:
//        guard !src.timeline.last!.isEmpty else { break }
//        let idxp = src.timeline.last!.randomIndexPath(i)
//        let k = src.timeline.last!.identity(at: idxp)
//        let px = vc.proxyController.proxy(for: k)
//        vc.outlineView.expandItem(px, expandChildren: false)
//        opcounter[op, default: 0] += 1
//    case .collapse:
//        guard !src.timeline.last!.isEmpty else { break }
//        let idxp = src.timeline.last!.randomIndexPath(i)
//        let k = src.timeline.last!.identity(at: idxp)
//        let px = vc.proxyController.proxy(for: k)
//        vc.outlineView.collapseItem(px, collapseChildren: false)
//        opcounter[op, default: 0] += 1
//    }
//    if i % 1000 == 0 {
//        print("\(i)/\(c): c=\(src.timeline.last!.count) \(opcounter)")
//    }
//}
//
//print("finished.")
