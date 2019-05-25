//
//  TestTreeView1.swift
//  OT4ViewDemo
//
//  Created by Henry on 2019/05/25.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation
import AppKit
import OT4

@IBDesignable
final class TestTreeView1: NSView {
    private typealias Source = OT4Source<Int,String>
    private typealias View = OT4View<Source,OT4ItemView<String>>
    private let ot4v = View()
    private var src = Source()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        install()
    }
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        install()
    }
    private func install() {
        addSubview(ot4v)
        ot4v.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ot4v.centerXAnchor.constraint(equalTo: centerXAnchor),
            ot4v.centerYAnchor.constraint(equalTo: centerYAnchor),
            ot4v.widthAnchor.constraint(equalTo: widthAnchor),
            ot4v.heightAnchor.constraint(equalTo: heightAnchor),
            ])
        ot4v.note = { [weak self] n in self?.process(n) }
        fillDemoData()
    }
    private func fillDemoData() {
//        do {
//            let c = 10_000
//            let opidxs = Array(0..<c).shuffled()
//            src.timeline.insert("\(-c)", for: -c, at: [])
//            for i in 1..<c {
//                let idxp = src.timeline.last!.randomIndexPath(i) ?? []
//                let idxp1 = (idxp == [] || opidxs[i] % 2 == 0) ? idxp.appending(0) : idxp
//                src.timeline.insert("\(-i)", for: -i, at: idxp1)
//                if i % 1_000 == 0 {
//                    print("inserted \(i)...")
//                }
//            }
//        }

        src.timeline.insert("This", for: 1, at: [])
        src.timeline.insert("is", for: 2, at: [0])
        src.timeline.insert("a", for: 3, at: [0,0])
        src.timeline.insert("demo!", for: 4, at: [1])
        ot4v.control(.render(src))
    }
    private func process(_ n: View.Note) {
        switch n {
        case .interaction(let ix):
            let ids = Array(ix.selectedIdentities)
            print("selected: \(ids)")
//            ot4v.control(.render(src))
        }
    }
}

private final class TestTreeCell1: NSTableCellView, OT4ItemViewProtocol {
    public typealias State = String
    public func control(_ c: OT4ItemViewControl<TestTreeCell1.State>) {
        if textField == nil {
            let v = NSTextField()
            v.isBordered = false
            v.drawsBackground = false
            textField = v
            addSubview(v)
        }
        switch c {
        case .render(let s):
            textField?.stringValue = s
        }
    }
    public var note: ((OT4ItemViewNote<TestTreeCell1.State>) -> Void)?
}

extension String: OT4DefaultProtocol {
    public static var `default`: String { return "" }
}

private let idxs = Array(0..<1_000_000).shuffled()

//extension OT4Timeline {
//    func randomIndexPath(_ i: Int) -> IndexPath {
//        return last!.randomIndexPath(i)
//    }
//}
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
