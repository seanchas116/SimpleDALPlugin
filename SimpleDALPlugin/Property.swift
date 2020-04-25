//
//  Property.swift
//  SimpleDALPlugin
//
//  Created by 池上涼平 on 2020/04/25.
//  Copyright © 2020 com.seanchas116. All rights reserved.
//

import Foundation

protocol PropertyValue {
    var dataSize: UInt32 { get }
    func toData(data: UnsafeMutableRawPointer)
}

extension String: PropertyValue {
    var dataSize: UInt32 {
        return UInt32(MemoryLayout<CFString>.size)
    }
    func toData(data: UnsafeMutableRawPointer) {
        let cfString = self as CFString
        let unmanagedCFString = Unmanaged<CFString>.passRetained(cfString)
        UnsafeMutablePointer<Unmanaged<CFString>>(OpaquePointer(data)).pointee = unmanagedCFString
    }
}

extension CMFormatDescription: PropertyValue {
    var dataSize: UInt32 {
        return UInt32(MemoryLayout<Self>.size)
    }
    func toData(data: UnsafeMutableRawPointer) {
        let unmanaged = Unmanaged<Self>.passRetained(self as! Self)
        UnsafeMutablePointer<Unmanaged<Self>>(OpaquePointer(data)).pointee = unmanaged
    }
}

extension UInt32: PropertyValue {
    var dataSize: UInt32 {
        return UInt32(MemoryLayout<UInt32>.size)
    }
    func toData(data: UnsafeMutableRawPointer) {
        UnsafeMutablePointer<UInt32>(OpaquePointer(data)).pointee = self
    }
}

extension Int32: PropertyValue {
    var dataSize: UInt32 {
        return UInt32(MemoryLayout<Int32>.size)
    }
    func toData(data: UnsafeMutableRawPointer) {
        UnsafeMutablePointer<Int32>(OpaquePointer(data)).pointee = self
    }
}

extension Float64: PropertyValue {
    var dataSize: UInt32 {
        return UInt32(MemoryLayout<Float64>.size)
    }
    func toData(data: UnsafeMutableRawPointer) {
        UnsafeMutablePointer<Float64>(OpaquePointer(data)).pointee = self
    }
}

class Property {
    let getter: () -> PropertyValue
    let isSettable = false

    var dataSize: UInt32 {
        getter().dataSize
    }

    convenience init(_ value: PropertyValue) {
        self.init(getter: { value })
    }

    init(getter: @escaping () -> PropertyValue) {
        self.getter = getter
    }

    func getData(data: UnsafeMutableRawPointer) {
        let value = getter()
        value.toData(data: data)
    }
    func setData(data: UnsafeRawPointer) {
        // TODO
    }
}
