//
//  Main.swift
//  SimpleDALPlugin
//
//  Created by 池上涼平 on 2020/04/25.
//  Copyright © 2020 com.seanchas116. All rights reserved.
//

import Foundation
import os.log

@_cdecl("simpleDALPluginMain")
func simpleDALPluginMain(allocator: CFAllocator, requestedTypeUUID: CFUUID) -> UnsafeRawPointer {
    os_log("simpleDALPluginMain")
    return UnsafeRawPointer(bitPattern: 0)!
}
