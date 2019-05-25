//
//  MM.swift
//  OT4VTTUnitTests
//
//  Created by Henry on 2019/05/25.
//  Copyright © 2019 Eonil. All rights reserved.
//

/// Memory Manager.
///
/// Accoridng to end-user's usage pattern,
/// most nodes contain small number (<32) of items.
/// Therefore we can configure some compact storage for many of them.
/// MM pre-allocates a space which can store N of 8 length arrays of `T`.
///
/// For config of this;
///
///     smallestArrayLength:    8
///     smallestArrayCount:     128
///     steppingExponent:       1
///     steppingCount:          4
///
/// these spaces will be pre-allocated.
/// - 8 * 128 slots
/// - 16 * 64 slots
/// - 32 * 32 slots
/// - 64 * 16 slots
///
/// In total: (8*128=1024) + (16*64=1024) + (32*32=1024) + (64*16=1024) = 4096 items.
///
/// For 8-byte units, you'll get 32KiB memory which can contain about 100~200 small arrays.
/// This size can be stored in CPU cache.
///
/// These conditions are applied.
///
///     precondition(x.unitStrideInBytes >= 1)
///     precondition(x.smallestArrayLength >= 8)
///     precondition(x.smallestArrayCount >= 16)
///     precondition(x.steppingScale >= 2)
///     precondition(x.steppingCount >= 1)
///     precondition(x.steppingCount <= 4)
///
final class MM {
    let config: MMConfig
    private var slots: UnsafeMutableRawPointer
    init(config x: MMConfig) {
        precondition(x.unitStrideInBytes >= 1)
        precondition(x.smallestArrayLength >= 8)
        precondition(x.smallestArrayCount >= 16)
        precondition(x.steppingScale >= 2)
        precondition(x.steppingCount >= 1)
        precondition(x.steppingCount <= 4)
        config = x
        slots = .allocate(
            byteCount: x.totalSizeInBytes,
            alignment: x.unitStrideInBytes)
    }
    deinit {
        slots.deallocate()
    }
    func find(level lv: Int, at i: Int) -> UnsafeMutableRawBufferPointer {
        let r = config.findOffsetInBytes(level: lv, index: i)
        let p = slots.advanced(by: r.startIndex)
        let c = r.count
        return UnsafeMutableRawBufferPointer(start: p, count: c)
    }
}

struct MMConfig {
    var unitStrideInBytes = MemoryLayout<UInt>.stride
    var smallestArrayLengthExponent = 3 // 2^3 = 8
    var smallestArrayCountExponent = 7 // 2^7 = 128
    /// Next step's array length/count are
    ///
    ///     arrlen = arrlen << x.steppingExponent
    ///     arrc = arrc >> x.steppingExponent
    ///
    var steppingScaleExponent = 1 // 2^1 = 2
    var steppingCountExponent = 2 // 2^2 = 4

    var smallestArrayLength: Int {
        return 0b1 << smallestArrayLengthExponent
    }
    var smallestArrayCount: Int {
        return 0b1 << smallestArrayCountExponent
    }
    var steppingScale: Int {
        return 0b1 << steppingScaleExponent
    }
    var steppingCount: Int {
        return 0b1 << steppingCountExponent
    }
    var levelSizeInBytes: Int {
        return smallestArrayLength * smallestArrayCount * unitStrideInBytes
    }
    var totalSizeInBytes: Int {
        return levelSizeInBytes << steppingCount
    }
    func findOffset(level lv: Int, index i: Int) -> Range<Int> {
        let scaleexp = steppingScaleExponent
        let arrlen = smallestArrayLength << (lv * scaleexp)
        let arrc = smallestArrayCount << (lv * scaleexp)
        let start = arrlen * i
        let end = start + arrc
        return start..<end
    }
    func findOffsetInBytes(level lv: Int, index i: Int) -> Range<Int> {
        let r = findOffset(level: lv, index: i)
        return (r.startIndex * unitStrideInBytes)..<(r.endIndex * unitStrideInBytes)
    }
}
