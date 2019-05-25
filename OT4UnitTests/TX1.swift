//
//  ValueTree.swift
//  OT4ViewUnitTests
//
//  Created by Henry on 2019/05/19.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation
@testable import OT4

struct TX1<T>: TreeProtocol {
    var value: T
    var subtrees = [TX1]()
}
extension TX1: Equatable where T: Equatable {}

extension TX1 {
    func map<U>(_ fx: (T) -> U) -> TX1<U> {
        let v1 = fx(value)
        let sts = subtrees.map({ n in n.map(fx) })
        let tx1 = TX1<U>(value: v1, subtrees: sts)
        return tx1
    }
    func filterDescendants(_ fx: (T) -> Bool) -> TX1 {
        var copy = self
        copy.subtrees = subtrees.compactMap({ x in
            guard fx(x.value) else { return nil }
            let x1 = x.filterDescendants(fx)
            return x1
        })
        return copy
    }
}
extension TreeProtocol {
    func mapToIndexPathTree(base idxp: IndexPath = []) -> TX1<IndexPath> {
        var x = TX1<IndexPath>(value: idxp, subtrees: [])
        for (i,n) in subtrees.enumerated() {
            let idxp1 = idxp.appending(i)
            let x1 = n.mapToIndexPathTree(base: idxp1)
            x.subtrees.append(x1)
        }
        return x
    }
}

extension TreeProtocol where SubtreeCollection.Index == Int {
    /// Collects only index-paths for elements that are included by filter function.
    /// Descendant nodes will also be filtered out.
    func collectAllIndexPathsDFS(isIncluded fx: (IndexPath) -> Bool = { _ in true }) -> [IndexPath] {
        return collectAllEnumeratedDFS(isIncluded: { idxp,_ in fx(idxp) }).map({ idxp,_ in idxp })
    }
    /// Collects only elements that are included by filter function with index-paths for them.
    /// Descendant nodes will also be filtered out.
    func collectAllEnumeratedDFS(isIncluded fx: (IndexPath,Self) -> Bool = { _,_ in true }) -> [(IndexPath,Self)] {
        var a = [(IndexPath,Self)]()
        collectAllEnumeratedDFS(with: [], isIncluded: fx, into: &a)
        return a
    }
    /// Collects only elements that are included by filter function with index-paths for them.
    /// Descendant nodes will also be filtered out.
    private func collectAllEnumeratedDFS(with idxp: IndexPath, isIncluded fx: (IndexPath,Self) -> Bool = { _,_ in true }, into a: inout [(IndexPath,Self)]) {
        let e = (idxp,self)
        guard fx(e.0, e.1) else { return }
        a.append(e)
        for (i,x) in subtrees.enumerated() {
            let idxp1 = idxp.appending(i)
            x.collectAllEnumeratedDFS(with: idxp1, isIncluded: fx, into: &a)
        }
    }
}

extension TreeProtocol {
    func collectAll() -> [Self] {
        var a = [Self]()
        collectAll(into: &a)
        return a
    }
    private func collectAll(into a: inout [Self]) {
        a.append(self)
        for t1 in subtrees {
            t1.collectAll(into: &a)
        }
    }
}






