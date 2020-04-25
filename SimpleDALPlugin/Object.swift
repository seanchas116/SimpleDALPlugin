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
    func isPropertySettable(address: CMIOObjectPropertyAddress) -> Bool
    func getPropertyDataSize(address: CMIOObjectPropertyAddress) -> UInt32
    func getPropertyData(address: CMIOObjectPropertyAddress, dataSize: inout UInt32, data: UnsafeMutableRawPointer)
    func setPropertyData(address: CMIOObjectPropertyAddress, data: UnsafeRawPointer)
}

extension Object {
    func hasProperty(address: CMIOObjectPropertyAddress) -> Bool {
        return getPropertyDataSize(address: address) != 0
    }
}

var objects = [CMIOObjectID: Object]()

func addObject(object: Object) {
    objects[object.objectID] = object
}
