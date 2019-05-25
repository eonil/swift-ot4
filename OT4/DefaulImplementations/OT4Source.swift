//
//  OT4Source.swift
//  OT4
//
//  Created by Henry on 2019/05/25.
//  Copyright © 2019 Eonil. All rights reserved.
//

import Foundation

/// Default implementation of `OT4SourceProtocol`.
public struct OT4Source<Identity,State>: OT4SourceProtocol where Identity: Hashable {
    public var timeline = OT4Timeline<Identity,State>.default
    public init() {}
}
