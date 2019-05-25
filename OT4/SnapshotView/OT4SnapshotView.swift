//
//  OT4SnapshotView.swift
//  OT4
//
//  Created by Henry on 2019/05/25.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation
import AppKit

/// Simplified version of `OT4View`.
///
/// Though `OT4View` provides precise tracking of
/// each node identity with `<O(n)` time, sometimes
/// you need simplicity more than performance.
/// This view provides simple tree snapshot value
/// based rendering for you.
///
/// In this class, you can use simplified tree data,
/// but rendering always takes `O(n)` time.
///
/// - Complexity:
///     All rendering control takes `O(n)` time.
///
/// - Note:
///     `Value` should conform `LosslessStringConvertible`.
///
/// - Note:
///     Use `OT4View` if you want faster rendering.
///
public final class OT4SnapshotView<Source>: NSView where
Source: OT4KeyValueTreeProtocol,
Source.SubtreeCollection.Index == Int,
Source.Value: LosslessStringConvertible {
    public enum Control {
        case render(Source)
    }
    public enum Note {
        case interaction(Interaction)
    }
    public typealias Interaction = OT4Interaction<OT4Snapshot<Source.Key,Source.Value>>

    public func control(_ c: Control) {
        switch c {
        case .render(let s):
            var s1 = InnerSource()
            s.snapshot(path: [], into: &s1.timeline)
            ot4v.control(.render(s1))
        }
    }
    public var note: ((Note) -> Void)?

    ////

    private typealias InnerSource = OT4Source<Source.Key,Source.Value>
    private typealias InnerView = OT4View<InnerSource,OT4ItemView<Source.Value>>
    private let ot4v = InnerView()
    override init(frame f: NSRect) {
        super.init(frame: f)
        install()
    }
    required init?(coder c: NSCoder) {
        super.init(coder: c)
        install()
    }
    private func install() {
        addSubview(ot4v)
        ot4v.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ot4v.leftAnchor.constraint(equalTo: leftAnchor),
            ot4v.rightAnchor.constraint(equalTo: rightAnchor),
            ot4v.topAnchor.constraint(equalTo: topAnchor),
            ot4v.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        ot4v.note = { [weak self] n in self?.process(n) }
    }
    private func process(_ n: InnerView.Note) {
        switch n {
        case .interaction(let ix):
            note?(.interaction(ix))
        }
    }
}

private extension OT4KeyValueTreeProtocol where SubtreeCollection.Index == Int {
    func snapshot(path idxp: IndexPath, into s: inout OT4Timeline<Key,Value>) {
        precondition(s.isEmpty)
        s.insert(value, for: key, at: idxp)
        for i in subtrees.indices {
            let idxp1 = idxp.appending(i)
            snapshot(path: idxp1, into: &s)
        }
    }
}
