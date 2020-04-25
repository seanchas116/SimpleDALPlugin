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

    var formatDescription: CMVideoFormatDescription? {
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
    }

    func isPropertySettable(address: CMIOObjectPropertyAddress) -> Bool {
        return false
    }

    func getPropertyDataSize(address: CMIOObjectPropertyAddress) -> UInt32 {
        switch (Int(address.mSelector)) {
        case kCMIOObjectPropertyName:
            return String.dataSize
        case kCMIOStreamPropertyFormatDescription:
            return CMFormatDescription.dataSize
        default:
            return 0
        }
    }

    func getPropertyData(address: CMIOObjectPropertyAddress, dataSize: inout UInt32, data: UnsafeMutableRawPointer) {
        dataSize = getPropertyDataSize(address: address)

        switch (Int(address.mSelector)) {
        case kCMIOObjectPropertyName:
            name.toData(data: data)
        case kCMIOStreamPropertyFormatDescription:
            formatDescription?.toData(data: data)
        default: break
        }
    }

    func setPropertyData(address: CMIOObjectPropertyAddress, data: UnsafeRawPointer) {
    }
}
