//
//  TreeProtocol.swift
//  TreeView
//
//  Created by Henry on 2019/05/07.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation

///
/// Tree version 3.
///
/// Tree version 1 has numerous limitations.
/// Tree version 2 is based on unique ID and table.
/// As it requires unique ID, it's harder to manage state and building
/// "views" around it.
///
protocol TreeProtocol {
    associatedtype SubtreeCollection: RandomAccessCollection where SubtreeCollection.Element == Self
    var subtrees: SubtreeCollection { get }
}
protocol MutableTreeProtocol: TreeProtocol where SubtreeCollection: MutableCollection {
    var subtrees: SubtreeCollection { get set }
}

//protocol KeyValueTreeProtocol where Self: TreeProtocol {
//    associatedtype Key: Hashable
//    associatedtype Value
//    var key: Key { get }
//    var value: Value { get }
//}
//protocol MutableKeyValueTreeProtocol where Self: MutableTreeProtocol & KeyValueTreeProtocol {
//    var key: Key { get set }
//    var value: Value { get set }
//}

