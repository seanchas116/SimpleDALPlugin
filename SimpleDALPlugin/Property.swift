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
    static func fromData(data: UnsafeRawPointer) -> Self
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
    static func fromData(data: UnsafeRawPointer) -> Self {
        fatalError("not implemented")
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
    static func fromData(data: UnsafeRawPointer) -> Self {
        fatalError("not implemented")
    }
}

struct CFTypeRefWrapper {
    let ref: CFTypeRef
}

extension CFTypeRefWrapper: PropertyValue {
    var dataSize: UInt32 {
        return UInt32(MemoryLayout<CFTypeRef>.size)
    }
    func toData(data: UnsafeMutableRawPointer) {
        let unmanaged = Unmanaged<CFTypeRef>.passRetained(ref)
        UnsafeMutablePointer<Unmanaged<CFTypeRef>>(OpaquePointer(data)).pointee = unmanaged
    }
    static func fromData(data: UnsafeRawPointer) -> Self {
        fatalError("not implemented")
    }
}

extension UInt32: PropertyValue {
    var dataSize: UInt32 {
        return UInt32(MemoryLayout<UInt32>.size)
    }
    func toData(data: UnsafeMutableRawPointer) {
        UnsafeMutablePointer<UInt32>(OpaquePointer(data)).pointee = self
    }
    static func fromData(data: UnsafeRawPointer) -> Self {
        return UnsafePointer<UInt32>(OpaquePointer(data)).pointee
    }
}

extension Int32: PropertyValue {
    var dataSize: UInt32 {
        return UInt32(MemoryLayout<Int32>.size)
    }
    func toData(data: UnsafeMutableRawPointer) {
        UnsafeMutablePointer<Int32>(OpaquePointer(data)).pointee = self
    }
    static func fromData(data: UnsafeRawPointer) -> Self {
        return UnsafePointer<Int32>(OpaquePointer(data)).pointee
    }
}

extension Float64: PropertyValue {
    var dataSize: UInt32 {
        return UInt32(MemoryLayout<Float64>.size)
    }
    func toData(data: UnsafeMutableRawPointer) {
        UnsafeMutablePointer<Float64>(OpaquePointer(data)).pointee = self
    }
    static func fromData(data: UnsafeRawPointer) -> Self {
        return UnsafePointer<Float64>(OpaquePointer(data)).pointee
    }
}

class Property {
    let getter: () -> PropertyValue
    let setter: ((UnsafeRawPointer) -> Void)?

    var isSettable: Bool {
        return setter != nil
    }

    var dataSize: UInt32 {
        getter().dataSize
    }

    convenience init<Element: PropertyValue>(_ value: Element) {
        self.init(getter: { value })
    }

    convenience init<Element: PropertyValue>(getter: @escaping () -> Element) {
        self.init(getter: getter, setter: nil)
    }

    init<Element: PropertyValue>(getter: @escaping () -> Element, setter: ((Element) -> Void)?) {
        self.getter = getter
        self.setter = { data in setter?(Element.fromData(data: data)) }
    }

    func getData(data: UnsafeMutableRawPointer) {
        let value = getter()
        value.toData(data: data)
    }

    func setData(data: UnsafeRawPointer) {
        setter?(data)
    }
}
