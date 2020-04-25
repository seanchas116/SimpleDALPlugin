//
//  Object.swift
//  SimpleDALPlugin
//
//  Created by 池上涼平 on 2020/04/25.
//  Copyright © 2020 com.seanchas116. All rights reserved.
//

import Foundation

protocol PropertyValue {
    static var dataSize: UInt32 { get }
    static func fromData(data: UnsafeRawPointer) -> Self
    func toData(data: UnsafeMutableRawPointer)
}

protocol PropertyType {
    var selector: CMIOObjectPropertySelector { get }
    var isSettable: Bool { get }
    func getData(dataSize: inout UInt32, data: UnsafeMutableRawPointer)
    func setData(data: UnsafeRawPointer)
}

class Property<Element: PropertyValue>: PropertyType {
    let selector: CMIOObjectPropertySelector
    private let getter: () -> Element
    private let setter: ((Element) -> Void)?

    convenience init(selector: CMIOObjectPropertySelector, value: Element) {
        self.init(selector: selector, getter: { value })
    }

    init(selector: CMIOObjectPropertySelector, getter: @escaping () -> Element, setter: ((Element) -> Void)? = nil) {
        self.selector = selector
        self.getter = getter
        self.setter = setter
    }

    var isSettable: Bool {
        return setter != nil
    }

    var value: Element {
        get {
            return getter()
        }
        set {
            setter?(newValue)
        }
    }

    func getData(dataSize: inout UInt32, data: UnsafeMutableRawPointer) {
        dataSize = Element.dataSize
        value.toData(data: data)
    }

    func setData(data: UnsafeRawPointer) {
        value = Element.fromData(data: data)
    }
}

protocol Object: class {
    var properties: [PropertyType] { get }
}

var objects = [CMIOObjectID: Object]()
