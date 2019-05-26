//
//  OT4Snapshot.extension.swift
//  OT4
//
//  Created by Henry on 2019/05/26.
//  Copyright © 2019 Eonil. All rights reserved.
//

extension OT4Snapshot {
    public mutating func removeSubtree(for id: Key) {
        let cids = children(of: id)
        for cid in cids.lazy.reversed() {
            removeSubtree(for: cid)
        }
        remove(for: id)
    }
}
