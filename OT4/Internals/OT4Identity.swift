//
//  OT4Identity.swift
//  TreeOutlineView
//
//  Created by Henry on 2019/05/11.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation

/// Convenient global uniqueness based on pointer.
final class OT4Identity: Hashable {
    static func == (_ a: OT4Identity, _ b: OT4Identity) -> Bool {
        return ObjectIdentifier(a) == ObjectIdentifier(b)
    }
    func hash(into hasher: inout Hasher) {
        let id = ObjectIdentifier(self)
        hasher.combine(id)
    }
}
