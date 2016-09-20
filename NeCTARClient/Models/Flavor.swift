//
//  Flavor.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/8/22.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Flavor {
    var id: Int
    var disk: Int
    var name: String
    var ram: Int
    var vcpus: Int
    
    init?(json: JSON) {
        id = json["id"].intValue
        disk = json["disk"].intValue
        name = json["name"].stringValue
        ram = json["ram"].intValue
        vcpus = json["vcpus"].intValue
    }
}