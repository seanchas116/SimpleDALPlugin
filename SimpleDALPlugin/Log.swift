//
//  Log.swift
//  SimpleDALPlugin
//
//  Created by 池上涼平 on 2020/04/25.
//  Copyright © 2020 com.seanchas116. All rights reserved.
//

import Foundation

func log(_ message: Any = "", function: String = #function) {
    NSLog("SimpleDALPlugin: \(function): \(message)")
}
