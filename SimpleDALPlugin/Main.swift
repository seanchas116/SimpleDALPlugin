//
//  Main.swift
//  SimpleDALPlugin
//
//  Created by 池上涼平 on 2020/04/25.
//  Copyright © 2020 com.seanchas116. All rights reserved.
//

import Foundation
import CoreMediaIO
import os.log

typealias PluginRef = UnsafeMutablePointer<UnsafeMutablePointer<CMIOHardwarePlugInInterface>>

@_cdecl("simpleDALPluginMain")
func simpleDALPluginMain(allocator: CFAllocator, requestedTypeUUID: CFUUID) -> PluginRef {
    os_log("simpleDALPluginMain")

    var interface = CMIOHardwarePlugInInterface()

    let pluginRef = PluginRef.allocate(capacity: 1)
    pluginRef.pointee.initialize(to: interface)
    return pluginRef
}
