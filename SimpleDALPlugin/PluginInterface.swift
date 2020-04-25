//
//  PluginInterface.swift
//  SimpleDALPlugin
//
//  Created by 池上涼平 on 2020/04/25.
//  Copyright © 2020 com.seanchas116. All rights reserved.
//

import Foundation

func createPluginInterface() -> CMIOHardwarePlugInInterface {
    return CMIOHardwarePlugInInterface(
        _reserved: nil,
        QueryInterface: { (plugin: UnsafeMutableRawPointer?, uuid: REFIID, interface: UnsafeMutablePointer<LPVOID?>?) -> HRESULT in
            NSLog("QueryInterface")
            // return E_FAIL
            return HRESULT(bitPattern: 0x80000008)
        },
        AddRef: { (plugin: UnsafeMutableRawPointer?) -> ULONG in
            NSLog("AddRef")
            return 0
        },
        Release: { (plugin: UnsafeMutableRawPointer?) -> ULONG in
            NSLog("Release")
            return 0
        },
        Initialize: { (plugin: CMIOHardwarePlugInRef?) -> OSStatus in
            NSLog("Initialize")
            return OSStatus(kCMIOHardwareIllegalOperationError)
        },
        InitializeWithObjectID: { (plugin: CMIOHardwarePlugInRef?, objectID: CMIOObjectID) -> OSStatus in
            NSLog("InitializeWithObjectID")
            return OSStatus(kCMIOHardwareIllegalOperationError)
        },
        Teardown: { (plugin: CMIOHardwarePlugInRef?) -> OSStatus in
            NSLog("Teardown")
            return OSStatus(kCMIOHardwareIllegalOperationError)
        },
        ObjectShow: { (plugin: CMIOHardwarePlugInRef?, objectID: CMIOObjectID) in
            NSLog("ObjectShow")
        },
        ObjectHasProperty: { (plugin: CMIOHardwarePlugInRef?, objectID: CMIOObjectID, address: UnsafePointer<CMIOObjectPropertyAddress>?) -> DarwinBoolean in
            NSLog("ObjectHasProperty")
            return false
        },
        ObjectIsPropertySettable: { (plugin: CMIOHardwarePlugInRef?, objectID: CMIOObjectID, address: UnsafePointer<CMIOObjectPropertyAddress>?, isSettable: UnsafeMutablePointer<DarwinBoolean>?) -> OSStatus in
            NSLog("ObjectIsPropertySettable")
            return OSStatus(kCMIOHardwareIllegalOperationError)
        },
        ObjectGetPropertyDataSize: { (plugin: CMIOHardwarePlugInRef?, objectID: CMIOObjectID, address: UnsafePointer<CMIOObjectPropertyAddress>?, qualifiedDataSize: UInt32, qualifiedData: UnsafeRawPointer?, dataSize: UnsafeMutablePointer<UInt32>?) -> OSStatus in
            NSLog("ObjectGetPropertyDataSize")
            return OSStatus(kCMIOHardwareIllegalOperationError)
        },
        ObjectGetPropertyData: { (plugin: CMIOHardwarePlugInRef?, objectID: CMIOObjectID, address: UnsafePointer<CMIOObjectPropertyAddress>?, qualifiedDataSize: UInt32, qualifiedData: UnsafeRawPointer?, dataSize: UInt32, dataUsed: UnsafeMutablePointer<UInt32>?, data: UnsafeMutableRawPointer?) -> OSStatus in
            NSLog("ObjectGetPropertyData")
            return OSStatus(kCMIOHardwareIllegalOperationError)
        },
        ObjectSetPropertyData: { (plugin: CMIOHardwarePlugInRef?, objectID: CMIOObjectID, address: UnsafePointer<CMIOObjectPropertyAddress>?, qualifiedDataSize: UInt32, qualifiedData: UnsafeRawPointer?, dataSize: UInt32, data: UnsafeRawPointer?) -> OSStatus in
            NSLog("ObjectSetPropertyData")
            return OSStatus(kCMIOHardwareIllegalOperationError)
        },
        DeviceSuspend: { (plugin: CMIOHardwarePlugInRef?, deviceID: CMIODeviceID) -> OSStatus in
            NSLog("DeviceSuspend")
            return OSStatus(kCMIOHardwareIllegalOperationError)
        },
        DeviceResume: { (plugin: CMIOHardwarePlugInRef?, deviceID: CMIODeviceID) -> OSStatus in
            NSLog("DeviceResume")
            return OSStatus(kCMIOHardwareIllegalOperationError)
        },
        DeviceStartStream: { (plugin: CMIOHardwarePlugInRef?, deviceID: CMIODeviceID, streamID: CMIOStreamID) -> OSStatus in
            NSLog("DeviceStartStream")
            return OSStatus(kCMIOHardwareIllegalOperationError)
        },
        DeviceStopStream: { (plugin: CMIOHardwarePlugInRef?, deviceID: CMIODeviceID, streamID: CMIOStreamID) -> OSStatus in
            NSLog("DeviceStopStream")
            return OSStatus(kCMIOHardwareIllegalOperationError)
        },
        DeviceProcessAVCCommand: { (plugin: CMIOHardwarePlugInRef?, deviceID: CMIODeviceID, avcCommand: UnsafeMutablePointer<CMIODeviceAVCCommand>?) -> OSStatus in
            NSLog("DeviceProcessAVCCommand")
            return OSStatus(kCMIOHardwareIllegalOperationError)
        },
        DeviceProcessRS422Command: { (plugin: CMIOHardwarePlugInRef?, deviceID: CMIODeviceID, rs422Command: UnsafeMutablePointer<CMIODeviceRS422Command>?) -> OSStatus in
            NSLog("DeviceProcessRS422Command")
            return OSStatus(kCMIOHardwareIllegalOperationError)
        },
        StreamCopyBufferQueue: { (plugin: CMIOHardwarePlugInRef?, streamID: CMIOStreamID, queueAlteredProc: CMIODeviceStreamQueueAlteredProc?, queueAlteredRefCon: UnsafeMutableRawPointer?, queue: UnsafeMutablePointer<Unmanaged<CMSimpleQueue>?>?) -> OSStatus in
            NSLog("StreamCopyBufferQueue")
            return OSStatus(kCMIOHardwareIllegalOperationError)
        },
        StreamDeckPlay: { (plugin: CMIOHardwarePlugInRef?, streamID: CMIOStreamID) -> OSStatus in
            NSLog("StreamDeckPlay")
            return OSStatus(kCMIOHardwareIllegalOperationError)
        },
        StreamDeckStop: { (plugin: CMIOHardwarePlugInRef?, streamID: CMIOStreamID) -> OSStatus in
            NSLog("StreamDeckStop")
            return OSStatus(kCMIOHardwareIllegalOperationError)
        },
        StreamDeckJog: { (plugin: CMIOHardwarePlugInRef?, streamID: CMIOStreamID, speed: Int32) -> OSStatus in
            NSLog("StreamDeckJog")
            return OSStatus(kCMIOHardwareIllegalOperationError)
        },
        StreamDeckCueTo: { (plugin: CMIOHardwarePlugInRef?, streamID: CMIOStreamID, requestedTimecode: Float64, playOnCue: DarwinBoolean) -> OSStatus in
            NSLog("StreamDeckCueTo")
            return OSStatus(kCMIOHardwareIllegalOperationError)
        })
}
