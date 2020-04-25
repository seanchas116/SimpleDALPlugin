//
//  Object.swift
//  SimpleDALPlugin
//
//  Created by 池上涼平 on 2020/04/25.
//  Copyright © 2020 com.seanchas116. All rights reserved.
//

import Foundation

protocol Object: class {
    func hasProperty(address: CMIOObjectPropertyAddress) -> Bool
    func isPropertySettable(address: CMIOObjectPropertyAddress) -> Bool
    func getPropertyDataSize(address: CMIOObjectPropertyAddress) -> UInt32
    func getPropertyData(address: CMIOObjectPropertyAddress, out dataSize: UInt32, data: UnsafeMutableRawPointer)
    func setPropertyData(address: CMIOObjectPropertyAddress, data: UnsafeRawPointer)
}
