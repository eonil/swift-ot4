//
//  OT4Benchmark.swift
//  OT4
//
//  Created by Henry on 2019/05/25.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation

//#if OT4BENCHMARK
public func benchmark() {
    typealias Source = OT4Source<Int,Int>
    typealias VC = OT4VC2<Source,OT4ItemView<Int>>
    enum Op: String, CustomStringConvertible {
        case insert     =   "insert"
        case update     =   "update"
        case remove     =   "remove"
        case expand     =   "expand"
        case collapse   =   "collapse"
        var description: String {
            return rawValue
        }
        static let all = [.insert, .insert, .update, .remove, .expand, .collapse] as [Op]
    }

    print("preparing...")
    let vc = VC()
    var src = Source()
    do {
        let c = 100_000
        let opidxs = Array(0..<c).shuffled()
        src.timeline.insert(-c, for: -c, at: [])
        for i in 1..<c {
            let idxp = src.timeline.last!.randomIndexPath(i) ?? []
            let idxp1 = (idxp == [] || opidxs[i] % 2 == 0) ? idxp.appending(0) : idxp
            src.timeline.insert(-i, for: -i, at: idxp1)
            if i % 1_000 == 0 {
                print("inserted \(i)...")
            }
        }
    }

    let c = 1_000_000
    let opidxs = Array(0..<c).shuffled()
    let ks = Array(0..<c).shuffled()
    let vs = Array(0..<c).shuffled()
    var opcounter = [Op: Int]()
    sleep(1)
    
    print("started.")
//    src.timeline.insert(c, for: c, at: [])
    vc.process(.render(src))
    var timepoint = DispatchTime.now()
    for i in 0..<c {
        let op = Op.all[opidxs[i] % Op.all.count]
        switch op {
        case .insert:
            let idxp = src.timeline.last!.randomIndexPath(i) ?? []
            let idxp1 = (idxp != [] || opidxs[i] % 2 == 0) ? idxp : idxp.appending(0)
            guard idxp1 != [] else { break }
            let k = ks[i]
            let v = vs[i]
            src.timeline.insert(v, for: k, at: idxp1)
            vc.process(.render(src))
            opcounter[op, default: 0] += 1
        case .update:
            guard !src.timeline.last!.isEmpty else { break }
            let idxp = src.timeline.last!.randomIndexPath(i)!
            let k = src.timeline.last!.identity(at: idxp)
            let v = vs[i]
            let br = (opidxs[i] % 2 == 0 ? .branch : .leaf) as OT4Branchability
            src.timeline.update(v, for: k, as: br)
            vc.process(.render(src))
            opcounter[op, default: 0] += 1
        case .remove:
            guard !src.timeline.last!.isEmpty else { break }
            let idxp = src.timeline.last!.randomIndexPath(i)!
            guard idxp != [] else { break }
            let k = src.timeline.last!.identity(at: idxp)
            src.timeline.remove(for: k)
            vc.process(.render(src))
            opcounter[op, default: 0] += 1
        case .expand:
            guard !src.timeline.last!.isEmpty else { break }
            let idxp = src.timeline.last!.randomIndexPath(i)!
            let k = src.timeline.last!.identity(at: idxp)
            let px = vc.proxyTable.state(of: k)
            vc.outlineView.expandItem(px, expandChildren: false)
            opcounter[op, default: 0] += 1
        case .collapse:
            guard !src.timeline.last!.isEmpty else { break }
            let idxp = src.timeline.last!.randomIndexPath(i)!
            let k = src.timeline.last!.identity(at: idxp)
            let px = vc.proxyTable.state(of: k)
            vc.outlineView.collapseItem(px, collapseChildren: false)
            opcounter[op, default: 0] += 1
        }
        if i % 1000 == 0 {
            let newtp = DispatchTime.now()
            let dt = newtp.uptimeNanoseconds - timepoint.uptimeNanoseconds
            timepoint = newtp
            print("\(i)/\(c): c=\(src.timeline.last!.count) \(opcounter) t=\(dt / 1000)")
        }
    }

    print("finished.")

}

private let idxs = Array(0..<1_000_000).shuffled()

extension OT4Snapshot {
    func randomIndexPath(_ i: Int) -> IndexPath? {
        if isEmpty { return nil }
        let id = identity(at: [])
        return randomIndexPath(from: id, i)
    }
    private func randomIndexPath(from root: Identity, _ i: Int) -> IndexPath {
        let cs = children(of: root)
        guard cs.count > 0 else { return [] }
        let j = abs(i) % idxs.count
        let n = idxs[j] % cs.count
        let c = cs[n]
        return IndexPath().appending(n).appending(randomIndexPath(from: c, i.hashValue))
    }
}

//#endif
