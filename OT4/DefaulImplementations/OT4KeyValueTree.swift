//
//  OT4KeyValueTree.swift
//  OT4
//
//  Created by Henry on 2019/05/25.
//  Copyright © 2019 Eonil. All rights reserved.
//

/// Default implementation of `OT4KeyValueTreeProtocol`.
public struct OT4KeyValueTree<Key,Value>: OT4KeyValueTreeProtocol where Key: Hashable {
    public var key: Key
    public var value: Value
    public var subtrees = [OT4KeyValueTree]()
    public init(key k: Key, value v: Value) {
        key = k
        value = v
    }
}
