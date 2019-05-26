//
//  OT4View.swift
//  OT4View
//
//  Created by Henry on 2019/05/18.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation
import AppKit

/// Simplified `NSOutlineView` with value-based idempotent rendering.
///
/// - Make *source* value.
/// - Pass it to this view using `control` method.
/// - PROFIT!
///
/// Basically this view renders `OT4SourceProtocol` type value.
/// There's a default implementation of the protocol -- `OT4Source`,
/// and you can use this type to build source value.
///
/// - Complexity:
///     Rendering at best: O(n log n), where n is number of changed node.
///     Rendering at worst: O(n)
///
public final class OT4View<Source,ItemView>: NSView where
Source: OT4SourceProtocol,
Source.Timeline.Snapshot: OT4DefaultProtocol,
ItemView: OT4ItemViewProtocol,
ItemView.State == Source.Timeline.Snapshot.State {
    public typealias Interaction = OT4Interaction<Source.Timeline.Snapshot>

    public enum Control {
        case render(Source)
    }
    public enum Note {
        indirect case interaction(Interaction)
    }

    ////

    private let sv = NSScrollView()
    private let vc = OT4VC2<Source,ItemView>()

    public override init(frame f: NSRect) {
        super.init(frame: f)
        install()
    }
    public required init?(coder c: NSCoder) {
        super.init(coder: c)
        install()
    }
    private func install() {
        addSubview(sv)
        sv.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sv.centerXAnchor.constraint(equalTo: centerXAnchor),
            sv.centerYAnchor.constraint(equalTo: centerYAnchor),
            sv.widthAnchor.constraint(equalTo: widthAnchor),
            sv.heightAnchor.constraint(equalTo: heightAnchor),
            ])
        sv.documentView = vc.view
        vc.note = { [weak self] n in self?.note?(n) }
    }
    public func control(_ c: Control) {
        vc.control(c)
    }
    public var note: ((Note) -> Void)?
}

//final class OT4View<Source,ItemView> where
//
//    typealias Interaction = OT4Interaction<Source.Timeline.Snapshot>
//    enum Control {
//        case render(Source)
//    }
//    enum Note {
//        case interaction(Interaction)
//    }
//
//    private let vc = OT4VC<Source,ItemView>()
//}
//
