//
//  OT4ItemView.swift
//  OT4
//
//  Created by Henry on 2019/05/25.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation
import AppKit

/// Default implementation of `OT4ItemViewProtocol`.
public final class OT4ItemView<Value>: NSTableCellView, OT4ItemViewProtocol where
Value: LosslessStringConvertible {
    public func control(_ c: OT4ItemViewControl<Value>) {
        if textField == nil {
            let v = NSTextField()
            v.isBordered = false
            v.drawsBackground = false
            textField = v
            addSubview(v)
        }
        switch c {
        case .render(let s):
            textField?.stringValue = s.description
        }
    }
    public var note: ((OT4ItemViewNote<Value>) -> Void)?
}
