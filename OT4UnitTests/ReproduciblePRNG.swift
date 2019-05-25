//
//  ReproduciblePRNG.swift
//  OT4ViewUnitTests
//
//  Created by Henry on 2019/05/19.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation
import GameKit

struct ReproduciblePRNG {
    private var mt: GKMersenneTwisterRandomSource
    init(seed s: UInt64) {
        mt = GKMersenneTwisterRandomSource(seed: s)
    }
    mutating func next() -> Int {
        return abs(mt.nextInt())
    }
}
