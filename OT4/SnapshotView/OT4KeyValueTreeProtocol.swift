//
//  OT4KeyValueTreeProtocol.swift
//  OT4
//
//  Created by Henry on 2019/05/25.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation

public protocol OT4KeyValueTreeProtocol: OT4TreeProtocol {
    associatedtype Key: Hashable
    associatedtype Value
    /// Globally unique identity of this node in whole tree.
    var key: Key { get }
    var value: Value { get }
}
extension OT4KeyValueTreeProtocol {
    func iterateAll(_ fx: (Self) -> Void) {
        fx(self)
        for x in subtrees {
            x.iterateAll(fx)
        }
    }
}

public protocol OT4TreeProtocol {
    associatedtype SubtreeCollection: RandomAccessCollection where
        SubtreeCollection.Element == Self
    var subtrees: SubtreeCollection { get }
}
