//
//  Object.swift
//  SimpleDALPlugin
//
//  Created by 池上涼平 on 2020/04/25.
//  Copyright © 2020 com.seanchas116. All rights reserved.
//

import Foundation

protocol Object: class {
    var objectID: CMIOObjectID { get }
    var properties: [Int: Property] { get }
}

extension Object {
    func hasProperty(address: CMIOObjectPropertyAddress) -> Bool {
        return properties[Int(address.mSelector)] != nil
    }

    func isPropertySettable(address: CMIOObjectPropertyAddress) -> Bool {
        guard let property = properties[Int(address.mSelector)] else {
            return false
        }
        return property.isSettable
    }

    func getPropertyDataSize(address: CMIOObjectPropertyAddress) -> UInt32 {
        guard let property = properties[Int(address.mSelector)] else {
            return 0
        }
        return property.dataSize
    }

    func getPropertyData(address: CMIOObjectPropertyAddress, dataSize: inout UInt32, data: UnsafeMutableRawPointer) {
        guard let property = properties[Int(address.mSelector)] else {
            return
        }
        dataSize = property.dataSize
        property.getData(data: data)
    }

    func setPropertyData(address: CMIOObjectPropertyAddress, data: UnsafeRawPointer) {
        guard let property = properties[Int(address.mSelector)] else {
            return
        }
        property.setData(data: data)
    }
}

var objects = [CMIOObjectID: Object]()

func addObject(object: Object) {
    objects[object.objectID] = object
}
