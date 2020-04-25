//
//  Device.swift
//  SimpleDALPlugin
//
//  Created by 池上涼平 on 2020/04/25.
//  Copyright © 2020 com.seanchas116. All rights reserved.
//

import Foundation
import IOKit

class Device: Object {
    var objectID: CMIOObjectID = 0
    let name = "SimpleDALPlugin"
    let deviceUID = "SimpleDALPlugin Device"

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
            return String.dataSize
        case kCMIODevicePropertyDeviceUID:
            return String.dataSize
        case kCMIODevicePropertyTransportType:
            return UInt32.dataSize
        default:
            return 0
        }
    }

    func getPropertyData(address: CMIOObjectPropertyAddress, dataSize: inout UInt32, data: UnsafeMutableRawPointer) {
        dataSize = getPropertyDataSize(address: address)

        switch (Int(address.mSelector)) {
        case kCMIOObjectPropertyName:
            name.toData(data: data)
        case kCMIODevicePropertyDeviceUID:
            deviceUID.toData(data: data)
        case kCMIODevicePropertyTransportType:
            UInt32(kIOAudioDeviceTransportTypeBuiltIn).toData(data: data)
        default: break
        }
    }

    func setPropertyData(address: CMIOObjectPropertyAddress, data: UnsafeRawPointer) {
    }
}
