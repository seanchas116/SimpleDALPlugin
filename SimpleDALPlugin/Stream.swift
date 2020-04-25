//
//  Stream.swift
//  SimpleDALPlugin
//
//  Created by 池上涼平 on 2020/04/25.
//  Copyright © 2020 com.seanchas116. All rights reserved.
//

import Foundation

class Stream: Object {
    var objectID: CMIOObjectID = 0
    let name = "SimpleDALPlugin"
    let width = 1280
    let height = 720

    lazy var formatDescription: CMVideoFormatDescription? = {
        var formatDescription: CMVideoFormatDescription?
        let err = CMVideoFormatDescriptionCreate(
            allocator: kCFAllocatorDefault,
            codecType: kCMVideoCodecType_422YpCbCr8,
            width: Int32(width), height: Int32(height),
            extensions: nil,
            formatDescriptionOut: &formatDescription)
        guard err == noErr else {
            log("CMVideoFormatDescriptionCreate Error: \(err)")
            return nil
        }
        return formatDescription
    }()

    lazy var clock: CFTypeRef? = {
        var clock = UnsafeMutablePointer<Unmanaged<CFTypeRef>?>.allocate(capacity: 1)

        let err = CMIOStreamClockCreate(
            kCFAllocatorDefault,
            "SimpleDALPlugin clock" as CFString,
            Unmanaged.passUnretained(self).toOpaque(),
            CMTimeMake(value: 1, timescale: 10),
            100, 10,
            clock);
        guard err == noErr else {
            log("CMIOStreamClockCreate Error: \(err)")
            return nil
        }
        return clock.pointee?.takeUnretainedValue()
    }()

    lazy var queue: CMSimpleQueue? = {
        var queue: CMSimpleQueue?
        let err = CMSimpleQueueCreate(
            allocator: kCFAllocatorDefault,
            capacity: 30,
            queueOut: &queue)
        guard err == noErr else {
            log("CMSimpleQueueCreate Error: \(err)")
            return nil
        }
        return queue
    }()

    lazy var properties: [Int : Property] = [
        kCMIOObjectPropertyName: Property(name),
        kCMIOStreamPropertyFormatDescription: Property(formatDescription!),
        kCMIOStreamPropertyDirection: Property(UInt32(0)),
        kCMIOStreamPropertyFrameRate: Property(Float64(30)),
        kCMIOStreamPropertyClock: Property(CFTypeRefWrapper(ref: clock!)),
    ]
}
