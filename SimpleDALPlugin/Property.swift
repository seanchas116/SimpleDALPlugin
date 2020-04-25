//
//  Property.swift
//  SimpleDALPlugin
//
//  Created by 池上涼平 on 2020/04/25.
//  Copyright © 2020 com.seanchas116. All rights reserved.
//

import Foundation

protocol PropertyValue {
    static var dataSize: UInt32 { get }
    func toData(data: UnsafeMutableRawPointer)
}

extension String: PropertyValue {
    static var dataSize: UInt32 {
        return UInt32(MemoryLayout<CFString>.size)
    }
    func toData(data: UnsafeMutableRawPointer) {
        let cfString = self as CFString
        let unmanagedCFString = Unmanaged<CFString>.passRetained(cfString)
        UnsafeMutablePointer<Unmanaged<CFString>>(OpaquePointer(data)).pointee = unmanagedCFString
    }
}
