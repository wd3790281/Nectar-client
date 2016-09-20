//
//  Instances.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/8/21.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Instance {
    var ip4Address: String
    var addresses: [String] = []
    var createTime: String
    var flavorID: String
    var flavorRel: String
    var hostId: String
    var id: String
    var imageId: String
    var imageRel: String
    var keyName: String
    var name: String
    var taskState: String
    var status: String
    var volumes: [String] = []
    
    init?(json: JSON) {
        ip4Address = json["accessIPv4"].stringValue
        let address = json["address"]["private"].arrayValue
        for j in address {
            addresses.append(j["addr"].stringValue)
        }
        createTime = json["created"].stringValue
        flavorID = json["flavor"]["id"].stringValue
        flavorRel = json["flavor"]["links"][0]["rel"].stringValue
        hostId = json["hostId"].stringValue
        id = json["id"].stringValue
        imageId = json["image"]["id"].stringValue
        imageRel = json["image"]["links"][0]["rel"].stringValue
        keyName = json["key_name"].stringValue
        name = json["name"].stringValue
//        var ts = json["OS-EXT-STS:task_state"]
        if let ts = json["OS-EXT-STS:task_state"].string where !ts.isEmpty  {
            taskState = ts
        } else {
            taskState = "no task"
        }
        
        status = json["status"].stringValue
        for js in json["os-extended-volumes:volumes_attached"].arrayValue {
            volumes.append(js["id"].stringValue)
        }
    }
    
}
