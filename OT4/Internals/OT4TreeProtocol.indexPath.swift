//
//  TreeProtocol.indexPath.swift
//  TreeView
//
//  Created by Henry on 2019/05/08.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation

extension OT4TreeProtocol where SubtreeCollection.Index == Int {
    subscript(_ idxp: IndexPath) -> Self {
        get {
            if idxp.isEmpty { return self }
            let n = subtrees[idxp[0]]
            return n[idxp.dropFirst()]
        }
    }

    /// Captures all elements on the path.
    func valuePath(for idxp: IndexPath) -> [Self] {
        var a = [Self]()
        valuePathReversed(for: idxp, into: &a)
        return a.reversed()
    }
    private func valuePathReversed(for idxp: IndexPath, into a: inout [Self]) {
        guard !idxp.isEmpty else {
            a.append(self)
            return
        }
        let n = subtrees[idxp[0]]
        return n.valuePathReversed(for: idxp.dropFirst(), into: &a)
    }
}

extension OT4MutableTreeProtocol where SubtreeCollection.Index == Int {
    subscript(_ idxp: IndexPath) -> Self {
        get {
            if idxp.isEmpty { return self }
            let n = subtrees[idxp[0]]
            return n[idxp.dropFirst()]
        }
        set(v) {
            if idxp.isEmpty {
                self = v
                return
            }
            subtrees[idxp[0]][idxp.dropFirst()] = v
        }
    }
}
