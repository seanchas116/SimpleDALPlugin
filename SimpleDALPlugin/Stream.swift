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
    private var sequenceNumber: UInt64 = 0
    private var queueAlteredProc: CMIODeviceStreamQueueAlteredProc?
    private var queueAlteredRefCon: UnsafeMutableRawPointer?

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

    func createPixelBuffer() -> CVPixelBuffer? {
        let pixelBuffer = CVPixelBuffer.create(size: CGSize(width: width, height: height))
        pixelBuffer?.modifyWithContext { [width, height] context in
            context.setFillColor(CGColor.init(red: 1, green: 0, blue: 0, alpha: 1))
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        }
        return pixelBuffer
    }

    func enqueueBuffer() {
        guard let queue = queue else {
            log("queue is nil")
            return
        }

        guard CMSimpleQueueGetCount(queue) < CMSimpleQueueGetCapacity(queue) else {
            log("queue is full")
            return
        }

        guard let pixelBuffer = createPixelBuffer() else {
            log("pixelBuffer is nil")
            return
        }

        var timing = CMSampleTimingInfo(
            duration: CMTime(value: 1000, timescale: 1000 * 30),
            presentationTimeStamp: CMTime(value: CMTimeValue(mach_absolute_time()), timescale: CMTimeScale(1000_000_000)),
            decodeTimeStamp: .invalid
        )

        var error = noErr

        error = CMIOStreamClockPostTimingEvent(
            timing.presentationTimeStamp, mach_absolute_time(), true, self.clock)
        guard error == noErr else {
            log("CMSimpleQueueCreate Error: \(error)")
            return
        }

        var formatDescription: CMFormatDescription?
        error = CMVideoFormatDescriptionCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            formatDescriptionOut: &formatDescription)
        guard error == noErr else {
            log("CMVideoFormatDescriptionCreateForImageBuffer Error: \(error)")
            return
        }

        sequenceNumber += 1

        let sampleBufferPtr = UnsafeMutablePointer<Unmanaged<CMSampleBuffer>?>.allocate(capacity: 1)
        error = CMIOSampleBufferCreateForImageBuffer(
            kCFAllocatorDefault,
            pixelBuffer,
            formatDescription,
            &timing,
            sequenceNumber,
            UInt32(kCMIOSampleBufferNoDiscontinuities),
            sampleBufferPtr
        )
        guard error == noErr else {
            log("CMIOSampleBufferCreateForImageBuffer Error: \(error)")
            return
        }

        CMSimpleQueueEnqueue(queue, element: sampleBufferPtr)
        queueAlteredProc?(objectID, sampleBufferPtr, queueAlteredRefCon)
    }
}
