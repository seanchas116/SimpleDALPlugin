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

    func hasProperty(address: CMIOObjectPropertyAddress) -> Bool {
        switch (Int(address.mSelector)) {
        case kCMIOObjectPropertyName:
            return true

        default:
            return false
        }
    }

    func isPropertySettable(address: CMIOObjectPropertyAddress) -> Bool {
        return false
    }

    func getPropertyDataSize(address: CMIOObjectPropertyAddress) -> UInt32 {
        switch (Int(address.mSelector)) {
        case kCMIOObjectPropertyName:
            return UInt32(MemoryLayout<CFString>.size)
        default:
            return 0
        }
    }

    func getPropertyData(address: CMIOObjectPropertyAddress, dataSize: inout UInt32, data: UnsafeMutableRawPointer) {
        dataSize = getPropertyDataSize(address: address)

        switch (Int(address.mSelector)) {
        case kCMIOObjectPropertyName:
            let cfName = name as CFString
            let unmanagedCFname = Unmanaged<CFString>.passRetained(cfName)
            UnsafeMutablePointer<Unmanaged<CFString>>(OpaquePointer(data)).pointee = unmanagedCFname
        default: break
        }
    }

    func setPropertyData(address: CMIOObjectPropertyAddress, data: UnsafeRawPointer) {
    }
}
