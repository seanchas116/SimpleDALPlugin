//
//  PluginInterface.swift
//  SimpleDALPlugin
//
//  Created by 池上涼平 on 2020/04/25.
//  Copyright © 2020 com.seanchas116. All rights reserved.
//

import Foundation

typealias PluginRef = UnsafeMutablePointer<UnsafeMutablePointer<CMIOHardwarePlugInInterface>>

private var refCount: ULONG = 0

func createPluginInterface() -> CMIOHardwarePlugInInterface {
    return CMIOHardwarePlugInInterface(
        _reserved: nil,
        QueryInterface: { (plugin: UnsafeMutableRawPointer?, uuid: REFIID, interface: UnsafeMutablePointer<LPVOID?>?) -> HRESULT in
            log("QueryInterface")
            let pluginRefPtr = UnsafeMutablePointer<PluginRef?>(OpaquePointer(interface))
            pluginRefPtr?.pointee = pluginRef
            refCount += 1
            return HRESULT(noErr)
        },
        AddRef: { (plugin: UnsafeMutableRawPointer?) -> ULONG in
            log("AddRef")
            refCount += 1
            return refCount
        },
        Release: { (plugin: UnsafeMutableRawPointer?) -> ULONG in
            log("Release")
            refCount -= 1
            return 0
        },
        Initialize: { (plugin: CMIOHardwarePlugInRef?) -> OSStatus in
            log("Initialize")
            return OSStatus(kCMIOHardwareIllegalOperationError)
        },
        InitializeWithObjectID: { (plugin: CMIOHardwarePlugInRef?, objectID: CMIOObjectID) -> OSStatus in
            log("InitializeWithObjectID")
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
        },
        Teardown: { (plugin: CMIOHardwarePlugInRef?) -> OSStatus in
            log("Teardown")
            return noErr
        },
        ObjectShow: { (plugin: CMIOHardwarePlugInRef?, objectID: CMIOObjectID) in
            log("ObjectShow")
        },

        ObjectHasProperty: { (plugin: CMIOHardwarePlugInRef?, objectID: CMIOObjectID, address: UnsafePointer<CMIOObjectPropertyAddress>?) -> DarwinBoolean in
            log("ObjectHasProperty: \(address?.pointee.mSelector)")
            guard let address = address?.pointee else {
                log("Address is nil")
                return false
            }
            guard let object = objects[objectID] else {
                log("Object not found")
                return false
            }
            return DarwinBoolean(object.hasProperty(address: address))
        },

        ObjectIsPropertySettable: { (plugin: CMIOHardwarePlugInRef?, objectID: CMIOObjectID, address: UnsafePointer<CMIOObjectPropertyAddress>?, isSettable: UnsafeMutablePointer<DarwinBoolean>?) -> OSStatus in
            log("ObjectIsPropertySettable: \(address?.pointee.mSelector)")
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
        },

        ObjectGetPropertyDataSize: { (plugin: CMIOHardwarePlugInRef?, objectID: CMIOObjectID, address: UnsafePointer<CMIOObjectPropertyAddress>?, qualifiedDataSize: UInt32, qualifiedData: UnsafeRawPointer?, dataSize: UnsafeMutablePointer<UInt32>?) -> OSStatus in
            log("ObjectGetPropertyDataSize")
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
        },

        ObjectGetPropertyData: { (plugin: CMIOHardwarePlugInRef?, objectID: CMIOObjectID, address: UnsafePointer<CMIOObjectPropertyAddress>?, qualifiedDataSize: UInt32, qualifiedData: UnsafeRawPointer?, dataSize: UInt32, dataUsed: UnsafeMutablePointer<UInt32>?, data: UnsafeMutableRawPointer?) -> OSStatus in
            log("ObjectGetPropertyData: \(address?.pointee.mSelector)")
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
        },

        ObjectSetPropertyData: { (plugin: CMIOHardwarePlugInRef?, objectID: CMIOObjectID, address: UnsafePointer<CMIOObjectPropertyAddress>?, qualifiedDataSize: UInt32, qualifiedData: UnsafeRawPointer?, dataSize: UInt32, data: UnsafeRawPointer?) -> OSStatus in
            log("ObjectSetPropertyData")

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
        },

        DeviceSuspend: { (plugin: CMIOHardwarePlugInRef?, deviceID: CMIODeviceID) -> OSStatus in
            log("DeviceSuspend")
            return noErr
        },

        DeviceResume: { (plugin: CMIOHardwarePlugInRef?, deviceID: CMIODeviceID) -> OSStatus in
            log("DeviceResume")
            return noErr
        },

        DeviceStartStream: { (plugin: CMIOHardwarePlugInRef?, deviceID: CMIODeviceID, streamID: CMIOStreamID) -> OSStatus in
            log("DeviceStartStream")
            guard let stream = objects[streamID] as? Stream else {
                log("no stream")
                return OSStatus(kCMIOHardwareBadObjectError)
            }
            stream.start()
            return noErr
        },

        DeviceStopStream: { (plugin: CMIOHardwarePlugInRef?, deviceID: CMIODeviceID, streamID: CMIOStreamID) -> OSStatus in
            log("DeviceStopStream")
            guard let stream = objects[streamID] as? Stream else {
                log("no stream")
                return OSStatus(kCMIOHardwareBadObjectError)
            }
            stream.stop()
            return noErr
        },

        DeviceProcessAVCCommand: { (plugin: CMIOHardwarePlugInRef?, deviceID: CMIODeviceID, avcCommand: UnsafeMutablePointer<CMIODeviceAVCCommand>?) -> OSStatus in
            log("DeviceProcessAVCCommand")
            return OSStatus(kCMIOHardwareIllegalOperationError)
        },

        DeviceProcessRS422Command: { (plugin: CMIOHardwarePlugInRef?, deviceID: CMIODeviceID, rs422Command: UnsafeMutablePointer<CMIODeviceRS422Command>?) -> OSStatus in
            log("DeviceProcessRS422Command")
            return OSStatus(kCMIOHardwareIllegalOperationError)
        },

        StreamCopyBufferQueue: { (plugin: CMIOHardwarePlugInRef?, streamID: CMIOStreamID, queueAlteredProc: CMIODeviceStreamQueueAlteredProc?, queueAlteredRefCon: UnsafeMutableRawPointer?, queueOut: UnsafeMutablePointer<Unmanaged<CMSimpleQueue>?>?) -> OSStatus in
            log("StreamCopyBufferQueue")
            guard let queueOut = queueOut else {
                log("no queueOut")
                return OSStatus(kCMIOHardwareBadObjectError)
            }
            guard let stream = objects[streamID] as? Stream else {
                log("no stream")
                return OSStatus(kCMIOHardwareBadObjectError)
            }
            guard let queue = stream.queue else {
                log("no queue")
                return OSStatus(kCMIOHardwareBadObjectError)
            }

            stream.queueAlteredProc = queueAlteredProc
            stream.queueAlteredRefCon = queueAlteredRefCon
            queueOut.pointee = Unmanaged<CMSimpleQueue>.passRetained(queue)

            return noErr
        },

        StreamDeckPlay: { (plugin: CMIOHardwarePlugInRef?, streamID: CMIOStreamID) -> OSStatus in
            log("StreamDeckPlay")
            return OSStatus(kCMIOHardwareIllegalOperationError)
        },
        StreamDeckStop: { (plugin: CMIOHardwarePlugInRef?, streamID: CMIOStreamID) -> OSStatus in
            log("StreamDeckStop")
            return OSStatus(kCMIOHardwareIllegalOperationError)
        },
        StreamDeckJog: { (plugin: CMIOHardwarePlugInRef?, streamID: CMIOStreamID, speed: Int32) -> OSStatus in
            log("StreamDeckJog")
            return OSStatus(kCMIOHardwareIllegalOperationError)
        },
        StreamDeckCueTo: { (plugin: CMIOHardwarePlugInRef?, streamID: CMIOStreamID, requestedTimecode: Float64, playOnCue: DarwinBoolean) -> OSStatus in
            log("StreamDeckCueTo")
            return OSStatus(kCMIOHardwareIllegalOperationError)
        })
}

let pluginRef: PluginRef = {
    let interfacePtr = UnsafeMutablePointer<CMIOHardwarePlugInInterface>.allocate(capacity: 1)
    interfacePtr.pointee = createPluginInterface()

    let pluginRef = PluginRef.allocate(capacity: 1)
    pluginRef.pointee = interfacePtr
    return pluginRef
}()
