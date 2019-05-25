////
////  OT4RefProxyController2.swift
////  OT4
////
////  Created by Henry on 2019/05/25.
////  Copyright © 2019 Eonil. All rights reserved.
////
//
//import Foundation
//
//struct OT4RefProxyController2<Identity> where Identity: Hashable {
//    typealias RefProxy = OT4RefProxy2<Identity>
//
//    private var table = OT4Snapshot<Identity, RefProxy>()
//    func find(_ id: Identity) -> RefProxy {
//        return table.state(of: id)
//    }
//    mutating func insert(_ id: Identity, at idxp: IndexPath) {
//        let px = RefProxy(identity: id)
//        table.insert(px, for: id, at: idxp)
//    }
//    mutating func remove(_ id: Identity) {
//        assert(table.children(of: id).count == 0)
//        table.remove(for: id)
//    }
//}
