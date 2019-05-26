//
//  OT4ItemViewProtocol.swift
//  OT4View
//
//  Created by Henry on 2019/05/19.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation
import AppKit

/// Represents a view that can render and edit a node state.
/// - TODO: Editing is not implemented yet.
public protocol OT4ItemViewProtocol: NSView {
    associatedtype State
    func control(_ c: Control)
    typealias Control = OT4ItemViewControl<State>
    var note: ((Note) -> Void)? { get set }
    typealias Note = OT4ItemViewNote<State>
}
public enum OT4ItemViewControl<State> {
    case render(State)
}
public enum OT4ItemViewNote<State> {
    case edit(State)
}

