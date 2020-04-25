//
//  PluginInterface.swift
//  SimpleDALPlugin
//
//  Created by 池上涼平 on 2020/04/25.
//  Copyright © 2020 com.seanchas116. All rights reserved.
//

import Foundation

typealias PluginRef = UnsafeMutablePointer<UnsafeMutablePointer<CMIOHardwarePlugInInterface>>

private func QueryInterface(plugin: UnsafeMutableRawPointer?, uuid: REFIID, interface: UnsafeMutablePointer<LPVOID?>?) -> HRESULT {
    log()
    let pluginRefPtr = UnsafeMutablePointer<PluginRef?>(OpaquePointer(interface))
    pluginRefPtr?.pointee = pluginRef
    return HRESULT(noErr)
}

private func AddRef(plugin: UnsafeMutableRawPointer?) -> ULONG {
    log()
    return 0
}

private func Release(plugin: UnsafeMutableRawPointer?) -> ULONG {
    log()
    return 0
}

private func Initialize(plugin: CMIOHardwarePlugInRef?) -> OSStatus {
    log()
    return OSStatus(kCMIOHardwareIllegalOperationError)
}

private func InitializeWithObjectID(plugin: CMIOHardwarePlugInRef?, objectID: CMIOObjectID) -> OSStatus {
    log()
    guard let plugin = plugin else {
        return OSStatus(kCMIOHardwareIllegalOperationError)
    }

    var error = noErr

    let pluginObject = Plugin()
    pluginObject.objectID = objectID
    addObject(object: pluginObject)

    let device = Device()
    error = CMIOObjectCreate(plugin, CMIOObjectID(kCMIOObjectSystemObject), CMIOClassID(kCMIODeviceClassID), &device.objectID)
    guard error == noErr else {
        log("error: \(error)")
        return error
    }
    addObject(object: device)

    let stream = Stream()
    error = CMIOObjectCreate(plugin, device.objectID, CMIOClassID(kCMIOStreamClassID), &stream.objectID)
    guard error == noErr else {
        log("error: \(error)")
        return error
    }
    addObject(object: stream)

    device.streamID = stream.objectID

    error = CMIOObjectsPublishedAndDied(plugin, CMIOObjectID(kCMIOObjectSystemObject), 1, &device.objectID, 0, nil)
    guard error == noErr else {
        log("error: \(error)")
        return error
    }

    error = CMIOObjectsPublishedAndDied(plugin, device.objectID, 1, &stream.objectID, 0, nil)
    guard error == noErr else {
        log("error: \(error)")
        return error
    }

    return noErr
}
private func Teardown(plugin: CMIOHardwarePlugInRef?) -> OSStatus {
    log()
    return noErr
}
private func ObjectShow(plugin: CMIOHardwarePlugInRef?, objectID: CMIOObjectID) {
    log()
}

private func ObjectHasProperty(plugin: CMIOHardwarePlugInRef?, objectID: CMIOObjectID, address: UnsafePointer<CMIOObjectPropertyAddress>?) -> DarwinBoolean {
    log(address?.pointee.mSelector)
    guard let address = address?.pointee else {
        log("Address is nil")
        return false
    }
    guard let object = objects[objectID] else {
        log("Object not found")
        return false
    }
    return DarwinBoolean(object.hasProperty(address: address))
}

private func ObjectIsPropertySettable(plugin: CMIOHardwarePlugInRef?, objectID: CMIOObjectID, address: UnsafePointer<CMIOObjectPropertyAddress>?, isSettable: UnsafeMutablePointer<DarwinBoolean>?) -> OSStatus {
    log(address?.pointee.mSelector)
    guard let address = address?.pointee else {
        log("Address is nil")
        return OSStatus(kCMIOHardwareBadObjectError)
    }
    guard let object = objects[objectID] else {
        log("Object not found")
        return OSStatus(kCMIOHardwareBadObjectError)
    }
    let settable = object.isPropertySettable(address: address)
    isSettable?.pointee = DarwinBoolean(settable)
    return noErr
}

private func ObjectGetPropertyDataSize(plugin: CMIOHardwarePlugInRef?, objectID: CMIOObjectID, address: UnsafePointer<CMIOObjectPropertyAddress>?, qualifiedDataSize: UInt32, qualifiedData: UnsafeRawPointer?, dataSize: UnsafeMutablePointer<UInt32>?) -> OSStatus {
    log(address?.pointee.mSelector)
    guard let address = address?.pointee else {
        log("Address is nil")
        return OSStatus(kCMIOHardwareBadObjectError)
    }
    guard let object = objects[objectID] else {
        log("Object not found")
        return OSStatus(kCMIOHardwareBadObjectError)
    }
    dataSize?.pointee = object.getPropertyDataSize(address: address)
    return noErr
}

private func ObjectGetPropertyData(plugin: CMIOHardwarePlugInRef?, objectID: CMIOObjectID, address: UnsafePointer<CMIOObjectPropertyAddress>?, qualifiedDataSize: UInt32, qualifiedData: UnsafeRawPointer?, dataSize: UInt32, dataUsed: UnsafeMutablePointer<UInt32>?, data: UnsafeMutableRawPointer?) -> OSStatus {
    log(address?.pointee.mSelector)
    guard let address = address?.pointee else {
        log("Address is nil")
        return OSStatus(kCMIOHardwareBadObjectError)
    }
    guard let object = objects[objectID] else {
        log("Object not found")
        return OSStatus(kCMIOHardwareBadObjectError)
    }
    guard let data = data else {
        log("data is nil")
        return OSStatus(kCMIOHardwareBadObjectError)
    }
    var dataUsed_: UInt32 = 0
    object.getPropertyData(address: address, dataSize: &dataUsed_, data: data)
    dataUsed?.pointee = dataUsed_
    return noErr
}

private func ObjectSetPropertyData(plugin: CMIOHardwarePlugInRef?, objectID: CMIOObjectID, address: UnsafePointer<CMIOObjectPropertyAddress>?, qualifiedDataSize: UInt32, qualifiedData: UnsafeRawPointer?, dataSize: UInt32, data: UnsafeRawPointer?) -> OSStatus {
    log()

    guard let address = address?.pointee else {
        log("Address is nil")
        return OSStatus(kCMIOHardwareBadObjectError)
    }
    guard let object = objects[objectID] else {
        log("Object not found")
        return OSStatus(kCMIOHardwareBadObjectError)
    }
    guard let data = data else {
        log("data is nil")
        return OSStatus(kCMIOHardwareBadObjectError)
    }
    object.setPropertyData(address: address, data: data)
    return noErr
}

private func DeviceSuspend(plugin: CMIOHardwarePlugInRef?, deviceID: CMIODeviceID) -> OSStatus {
    log()
    return noErr
}

private func DeviceResume(plugin: CMIOHardwarePlugInRef?, deviceID: CMIODeviceID) -> OSStatus {
    log()
    return noErr
}

private func DeviceStartStream(plugin: CMIOHardwarePlugInRef?, deviceID: CMIODeviceID, streamID: CMIOStreamID) -> OSStatus {
    log()
    guard let stream = objects[streamID] as? Stream else {
        log("no stream")
        return OSStatus(kCMIOHardwareBadObjectError)
    }
    stream.start()
    return noErr
}

private func DeviceStopStream(plugin: CMIOHardwarePlugInRef?, deviceID: CMIODeviceID, streamID: CMIOStreamID) -> OSStatus {
    log()
    guard let stream = objects[streamID] as? Stream else {
        log("no stream")
        return OSStatus(kCMIOHardwareBadObjectError)
    }
    stream.stop()
    return noErr
}

private func DeviceProcessAVCCommand(plugin: CMIOHardwarePlugInRef?, deviceID: CMIODeviceID, avcCommand: UnsafeMutablePointer<CMIODeviceAVCCommand>?) -> OSStatus {
    log()
    return OSStatus(kCMIOHardwareIllegalOperationError)
}

private func DeviceProcessRS422Command(plugin: CMIOHardwarePlugInRef?, deviceID: CMIODeviceID, rs422Command: UnsafeMutablePointer<CMIODeviceRS422Command>?) -> OSStatus {
    log()
    return OSStatus(kCMIOHardwareIllegalOperationError)
}

private func StreamCopyBufferQueue(plugin: CMIOHardwarePlugInRef?, streamID: CMIOStreamID, queueAlteredProc: CMIODeviceStreamQueueAlteredProc?, queueAlteredRefCon: UnsafeMutableRawPointer?, queueOut: UnsafeMutablePointer<Unmanaged<CMSimpleQueue>?>?) -> OSStatus {
    log()
    guard let queueOut = queueOut else {
        log("no queueOut")
        return OSStatus(kCMIOHardwareBadObjectError)
    }
    guard let stream = objects[streamID] as? Stream else {
        log("no stream")
        return OSStatus(kCMIOHardwareBadObjectError)
    }
    guard let queue = stream.copyBufferQueue(queueAlteredProc: queueAlteredProc, queueAlteredRefCon: queueAlteredRefCon) else {
        log("no queue")
        return OSStatus(kCMIOHardwareBadObjectError)
    }
    queueOut.pointee = Unmanaged<CMSimpleQueue>.passRetained(queue)
    return noErr
}

private func StreamDeckPlay(plugin: CMIOHardwarePlugInRef?, streamID: CMIOStreamID) -> OSStatus {
    log()
    return OSStatus(kCMIOHardwareIllegalOperationError)
}

private func StreamDeckStop(plugin: CMIOHardwarePlugInRef?, streamID: CMIOStreamID) -> OSStatus {
    log()
    return OSStatus(kCMIOHardwareIllegalOperationError)
}

private func StreamDeckJog(plugin: CMIOHardwarePlugInRef?, streamID: CMIOStreamID, speed: Int32) -> OSStatus {
    log()
    return OSStatus(kCMIOHardwareIllegalOperationError)
}

private func StreamDeckCueTo(plugin: CMIOHardwarePlugInRef?, streamID: CMIOStreamID, requestedTimecode: Float64, playOnCue: DarwinBoolean) -> OSStatus {
    log()
    return OSStatus(kCMIOHardwareIllegalOperationError)
}

private func createPluginInterface() -> CMIOHardwarePlugInInterface {
    return CMIOHardwarePlugInInterface(
        _reserved: nil,
        QueryInterface: QueryInterface,
        AddRef: AddRef,
        Release: Release,
        Initialize: Initialize,
        InitializeWithObjectID: InitializeWithObjectID,
        Teardown: Teardown,
        ObjectShow: ObjectShow,
        ObjectHasProperty: ObjectHasProperty,
        ObjectIsPropertySettable: ObjectIsPropertySettable,
        ObjectGetPropertyDataSize: ObjectGetPropertyDataSize,
        ObjectGetPropertyData: ObjectGetPropertyData,
        ObjectSetPropertyData: ObjectSetPropertyData,
        DeviceSuspend: DeviceSuspend,
        DeviceResume: DeviceResume,
        DeviceStartStream: DeviceStartStream,
        DeviceStopStream: DeviceStopStream,
        DeviceProcessAVCCommand: DeviceProcessAVCCommand,
        DeviceProcessRS422Command: DeviceProcessRS422Command,
        StreamCopyBufferQueue: StreamCopyBufferQueue,
        StreamDeckPlay: StreamDeckPlay,
        StreamDeckStop: StreamDeckStop,
        StreamDeckJog: StreamDeckJog,
        StreamDeckCueTo: StreamDeckCueTo)
}

let pluginRef: PluginRef = {
    let interfacePtr = UnsafeMutablePointer<CMIOHardwarePlugInInterface>.allocate(capacity: 1)
    interfacePtr.pointee = createPluginInterface()

    let pluginRef = PluginRef.allocate(capacity: 1)
    pluginRef.pointee = interfacePtr
    return pluginRef
}()
