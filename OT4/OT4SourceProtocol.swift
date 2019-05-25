//
//  OT4SourceProtocol.swift
//  OT4
//
//  Created by Henry on 2019/05/25.
//  Copyright © 2019 Eonil. All rights reserved.
//

public protocol OT4SourceProtocol {
    associatedtype Timeline: OT4TimelineProtocol
    var timeline: Timeline { get }
}
